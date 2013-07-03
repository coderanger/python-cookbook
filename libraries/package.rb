class Chef
  class Resource
    class PythonPackage < LWRPBase
      include PythonBase
      default_action :install
      actions :upgrade, :remove, :purge

      attribute :version, :default => nil
      attribute_user_and_group
    end
  end

  class Provider
    class PythonPackage < LWRPBase
      include PythonBase

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::PythonPackage.new(@new_resource.name)
        result = python_shell_out(%Q{python -c "print __import__('pkg_resources').working_set.by_key.get(#{@current_resource.name.downcase.to_json}).version"})
        @current_resource.version = result.stdout.strip if result.exitstatus == 0
        @current_resource
      end

      def latest_version
        script <<-EOH
from pip.index import PackageFinder
from pip.req import InstallRequirement
from pkg_resources import safe_name
from setuptools.package_index import distros_for_url
pkg = #{new_resource.name.to_json}
pkg_normalized = safe_name(pkg).lower()
req = InstallRequirement.from_line(pkg, None)
pf = PackageFinder(find_links=[], index_urls=['https://pypi.python.org/simple/'])
for dist in distros_for_url(pf.find_requirement(req, False).url):
    if safe_name(dist.project_name).lower() == pkg_normalized and dist.version:
      print dist.version
      break
EOH
        result = python_shell_out(%Q{python -c "#{script}"})
        result.stdout.strip if result.exitstatus == 0
      end

      def action_install
        # If we specified a version, and it's not the current version, move to the specified version
        install_version = if new_resource.version && new_resource.version != current_resource.version
          new_resource.version
        # If it's not installed at all, install it
        elsif !current_resource.version
          latest_version
        end

        if install_version
          converge_by("install package #{new_resource.name} version #{install_version}") do
            Chef::Log.info("Installing #{new_resource.name} version #{install_version}")
            python_shell_out!("pip install #{new_resource.name}==#{install_version}")
            new_resource.updated_by_last_action(true)
          end
        end
      end
    end
  end
end

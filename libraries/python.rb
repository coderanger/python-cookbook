# YOLO
Chef::Resource.send(:remove_const, :Python)

class Chef
  class Resource
    class Python < LWRPBase
      include PythonBase
      self.resource_name = :python
      default_action(:install)
      actions(:remove)

      attribute(:version, kind_of: String, default: nil, name_attribute: true)
      attribute(:implementation, kind_of: [String, Symbol], default: :cpython)
      user_and_group_attribute()

      def python_bin
        provider_for_action(self.action.is_a?(Array) ? self.action.first : self.action).python_bin
      end

      # Allow python_shell_out to work cleanly
      def python
        self
      end
    end
  end

  class Provider
    class Python < Provider
      include PythonBase

      def whyrun_supported?
        true
      end

      def install_setuptools
        result = python_shell_out('-c', 'import setuptools')
        if result.exitstatus && result.exitstatus != 0
          converge_by('install setuptools via ez_setup.py') do
            script = PythonHelpers.http_get('https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py')
            python_shell_out!(input: script)
          end
        end
      end

      def install_pip
        result = python_shell_out('-c' 'import pip')
        if result.exitstatus && result.exitstatus != 0
          converge_by('install pip via get-pip.py') do
            script = PythonHelpers.http_get('https://raw.github.com/pypa/pip/master/contrib/get-pip.py')
            python_shell_out!(input: script)
          end
        end
      end

      def install_virtualenv
        result = python_shell_out('-c' ,'import virtualenv')
        if result.exitstatus && result.exitstatus != 0
          converge_by('install virtualenv via pip') do
            python_shell_out!('-c', 'import pip,sys; sys.exit(pip.main())', 'install', 'virtualenv')
          end
        end
      end

      def action_install
        install_python
        install_setuptools
        install_pip
        install_virtualenv
      end

      # Overridden in subclasses
      def install_python
        raise NotImplementedError
      end

      def action_remove
        raise NotImplementedError
      end

      class Package < Python
        Chef::Platform.platforms[:default][:python] = self
        include Chef::DSL::PlatformIntrospection

        def package_name
          @package_name ||= if new_resource.implementation.to_sym == :cpython
            if platform_family?(:debian) && m = /^(\d)\.(\d)/.match(new_resource.version) # RPMs don't do python27 et al
              "python#{m[1]}.#{m[2]}"
            elsif new_resource.version && new_resource.version[0] == '3'
              'python3'
            else
              'python' # includes ver==null
            end
          else
            new_resource.implementation.to_s # covers pypy and similar most places
          end
        end

        # So this is probably a bad assumption, but it also seems to work pretty uniformly
        def python_bin
          ::File.join('', 'usr', 'bin', package_name)
        end

        def load_current_resource
          @pkg = Chef::Resource::Package.new(self.package_name, new_resource.run_context)
          @pkg_provider = @pkg.provider_for_action(:install)
          @pkg_provider.load_current_resource
          if new_resource.version && !(@pkg_provider.candidate_version && @pkg_provider.candidate_version.start_with?(new_resource.version))
            raise "Unable to find approriate package for #{new_resource.version}: #{@pkg.name}-#{@pkg_provider.candidate_version}"
          end
          if @pkg_provider.candidate_version.start_with?('3.0') || @pkg_provider.candidate_version.start_with?('3.1')
            # get-pip, and possibly other things just don't work on 3.0/1
            raise "Python version #{@pkg_provider.candidate_version} not supported"
          end
          @current_resource = Chef::Resource::Python.new(new_resource.name)
          m = /^(\d(\.\d(\.\d)?)?)/.match(@pkg_provider.current_resource.version)
          @current_resource.version(m ? m[1] : @pkg_provider.current_resource.version)
          @current_resource
        end

        def install_python
          @pkg.run_action(:install)
        end

        def action_remove
          @pkg.run_action(:remove)
        end
      end

      class Source < Python
        # Stub just to explain the structure
        # In the future this will do installs from source

        def install_python
          raise NotImplementedError
        end

        def action_remove
          raise NotImplementedError
        end
      end

    end
  end
end

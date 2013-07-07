# YOLO
Chef::Resource.send(:remove_const, :Python)

class Chef
  class Resource
    class Python < LWRPBase
      self.resource_name = :python
      default_action(:install)
      actions(:remove)

      attribute(:version, kind_of: String, default: nil, name_attribute: true)
      attribute(:implementation, kind_of: [String, Symbol], default: :cpython)
      # attribute(:user, regex: Chef::Config[:user_valid_regex]) # later
      # attribute(:group, regex: Chef::Config[:group_valid_regex])
    end
  end

  class Provider
    class Python

      class Package < Provider
        Chef::Platform.platforms[:default][:python] = self
        include Chef::DSL::PlatformIntrospection

        def whyrun_supported?
          true
        end

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

        def load_current_resource
          @pkg = Chef::Resource::Package.new(self.package_name, new_resource.run_context)
          @pkg_provider = @pkg.provider_for_action(:install)
          @pkg_provider.load_current_resource
          if new_resource.version && !(@pkg_provider.candidate_version && @pkg_provider.candidate_version.start_with?(new_resource.version))
            raise "Unable to find approriate package for #{new_resource.version}: #{@pkg.name}-#{@pkg_provider.candidate_version}"
          end
          @current_resource = Chef::Resource::Python.new(new_resource.name)
          m = /^(\d(\.\d(\.\d)?)?)/.match(@pkg_provider.current_resource.version)
          @current_resource.version(m ? m[1] : @pkg_provider.current_resource.version)
          @current_resource
        end

        def action_install
          @pkg.run_action(:install)
        end

        def action_remove
          @pkg.run_action(:remove)
        end
      end

    end
  end
end

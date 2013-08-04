class Chef
  class Resource
    class PythonVirtualenv < LWRPBase
      include PythonBase
      default_action(:create)
      actions(:remove)

      attribute(:path, name_attribute: true)
      user_and_group_attribute()
      parent_attribute(:python, type: :python)
    end
  end

  class Provider
    class PythonVirtualenv < Provider
      include PythonBase

      def load_current_resource
      end

      def action_create
      end

      def action_remove
        if ::File.exists?(@new_resource.path)
          converge_by("delete existing virtualenv #{new_resource.path}") do
            FileUtils.rm_rf(new_resource.path)
            Chef::Log.info("#{new_resource} deleted #{new_resource.path}")
          end
        end
      end
    end
  end
end

require 'chef/mixin/shell_out'

class Chef
  class Resource
    module PythonBase
      def virtualenv(arg = nil)
        arg = resources(python_virtualenv: arg) if arg.is_a?(String)
        set_or_return(:virtualenv, arg, kind_of: Chef::Resource)
      end

      def self.attribute_user_and_group
        self.attribute(:user, regex: Chef::Config[:user_valid_regex])
        self.attribute(:group, regex: Chef::Config[:group_valid_regex])
      end
    end
  end

  class Provider
    module PythonBase
      def self.included
        self.include(Chef::Mixin::ShellOut)
      end

      # Wrap shell_out
      def python_shell_out(cmd, *args)
        # Prepend the virtualenv to the command path if present
        cmd = ::File.join(new_resource.virtualenv, 'bin', cmd) if new_resource.virtualenv
        args << {} unless args.last.is_a?(Hash)
        options = args.last
        # Pass through user and group to all commands, use the virtualenv's params is present
        options[:user] = if new_resource.respond_to?(:user) && new_resource.user
          new_resource.user
        elsif new_resource.virtualenv
          new_resource.virtualenv.user
        end
        options[:group] = if new_resource.respond_to?(:group) && new_resource.group
          new_resource.group
        elsif new_resource.virtualenv
          new_resource.virtualenv.group
        end
        shell_out(cmd, *args)
      end

      # Similar to shell_out!
      def python_shell_out!(*args)
        cmd = python_shell_out(*args)
        cmd.error!
        cmd
      end
    end
  end
end
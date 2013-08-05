require 'chef/mixin/shell_out'

class Chef
  class Resource
    module PythonBase
      def virtualenv(arg = nil)
        arg = resources(python_virtualenv: arg) if arg.is_a?(String)
        set_or_return(:virtualenv, arg, kind_of: Chef::Resource)
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def parent_attribute(name, options={})
          type = options.delete(:type)
          self.send(:define_method, name) do |arg = nil|
            arg = resources(type => arg) if arg.is_a?(String)
            set_or_return(name, arg, {kind_of: Chef::Resource}.merge(options))
          end
        end

        def user_and_group_attribute(options={})
          self.attribute(:user, {regex: Chef::Config[:user_valid_regex]}.merge(options))
          self.attribute(:group, {regex: Chef::Config[:group_valid_regex]}.merge(options))
        end
      end
    end
  end

  class Provider
    module PythonBase
      def self.included(klass)
        klass.class_exec do
          include(Chef::Mixin::ShellOut)
        end
      end

      # Wrap shell_out
      def python_shell_out(*args)
        # Find the correct python binary
        python_bin = if new_resource.respond_to?(:virtualenv) && new_resource.virtualenv
          ::File.join(new_resource.virtualenv.path, 'bin', 'python')
        elsif new_resource.respond_to?(:python) && new_resource.python
          ::File.join(new_resource.python.python_bin)
        else
          'python'
        end
        args.insert(0, python_bin)
        args << {} unless args.last.is_a?(Hash)
        options = args.last
        # Pass through user and group to all commands, use the virtualenv's params is present
        options[:user] ||= if new_resource.respond_to?(:user) && new_resource.user
          new_resource.user
        elsif new_resource.respond_to?(:virtualenv) && new_resource.virtualenv
          new_resource.virtualenv.user
        elsif new_resource.respond_to?(:python) && new_resource.python
          new_resource.python.user
        end
        options[:group] ||= if new_resource.respond_to?(:group) && new_resource.group
          new_resource.group
        elsif new_resource.respond_to?(:virtualenv) && new_resource.virtualenv
          new_resource.virtualenv.group
        elsif new_resource.respond_to?(:python) && new_resource.python
          new_resource.python.group
        end
        shell_out(*args)
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

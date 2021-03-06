require "tagful/version"

module Tagful
  DEFAULT_ERROR_MODULE_NAME = 'Error'

  class NotFound < ArgumentError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def tagful_with(error_module_or_class)
      @tagful_error_module_or_class = error_module_or_class
    end

    def tagful(method_id, error_module_or_class = nil)
      visibility =
        case
        when public_method_defined?(method_id)
          :public
        when protected_method_defined?(method_id)
          :protected
        when private_method_defined?(method_id)
          :private
        else
          raise ::Tagful::NoMethod
        end

      if error_module_or_class.nil?
        if @tagful_error_module_or_class.is_a?(Class)
          error_class = @tagful_error_module_or_class
        else
          error_module = @tagful_error_module_or_class
          error_module ||= DEFAULT_ERROR_MODULE_NAME
        end
      else
        if error_module_or_class.is_a?(Class)
          error_class = error_module_or_class
        else
          error_module = error_module_or_class
        end
      end

      if error_class.nil? && error_module == DEFAULT_ERROR_MODULE_NAME
        error_module = class_eval(<<-CODE)
          unless defined?(#{error_module})
            module #{error_module}; end
          end
          #{error_module}
        CODE
      end

      tagful_methods_module = class_eval('module TagfulMethods; self; end')
      tagful_methods_module.module_eval do
        if error_class
          define_method(method_id) do |*args, &block|
            begin
              super(*args, &block)
            rescue => e
              raise error_class, e.message
            end
          end
        else
          define_method(method_id) do |*args, &block|
            begin
              super(*args, &block)
            rescue => e
              e.extend(error_module) and raise
            end
          end
        end
        send visibility, method_id
      end
      class_eval { prepend(tagful_methods_module) }

      method_id
    end
  end
end

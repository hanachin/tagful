require "tagful/version"

module Tagful
  class NotFound < ArgumentError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def tagful(method_id, error_module = nil)
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

      error_module ||= 'Error'

      class_eval(<<-CODE)
        unless defined?(#{error_module})
          module #{error_module}; end
        end

        module TagfulMethods
          #{visibility}
          def #{method_id}(*args)
            super
          rescue => e
            e.extend(#{error_module}) and raise
          end
        end

        prepend(TagfulMethods)
      CODE
      method_id
    end
  end
end

require "tagful/version"

module Tagful
  class NotFound < ArgumentError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def tagful(method_id)
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

      class_eval(<<-CODE)
        unless defined?(Error)
          # FIXME: make a tag module customizable
          module Error; end
        end

        module TagfulMethods
          #{visibility}
          def #{method_id}(*args)
            super
          rescue => e
            e.extend(Error) and raise
          end
        end

        prepend(TagfulMethods)
      CODE
      method_id
    end
  end
end

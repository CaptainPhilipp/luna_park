# frozen_string_literal: true

require 'forwardable'

module LunaPark
  module Extensions
    # The Runnable interface is a generic interface
    # containing a single `run()` method - which returns
    # a true
    module Validateable
      def self.included(klass)
        klass.include InstanceMethods
        klass.extend  ClassMethods
        super
      end

      module InstanceMethods
        extend Forwardable

        private

        def params
          raise Errors::AbstractMethod
        end

        def validation
          @validation ||= self.class.validate(params)
        end

        delegate %i[validate! valid? validation_errors valid_params] => :validation
      end

      module ClassMethods
        def validator(klass)
          @_validator = klass
        end

        def validate(params)
          @_validator&.validate(params)
        end
      end
    end
  end
end
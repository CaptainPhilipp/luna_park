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
        def validation_errors
          validation ? validation.errors : {}
        end

        def valid?
          validation ? validation.success? : true
        end

        private

        def valid_params
          validation ? validation.valid_params : params
        end

        def validation
          @validation ||= self.class._validate(params)
        end

        # :nocov:
        def params
          raise Errors::AbstractMethod
        end
        # :nocov:
      end

      module ClassMethods
        def validator(klass)
          @_validator = klass
        end

        def _validate(params)
          @_validator&.validate(params)
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'dry-validation'

module LunaPark
  module Validators
    class Dry
      def initialize(params)
        @params = params
      end

      def valid?
        warn 'DEPRECATED: Change `LunaPark::Validators::Dry#valid?` to `#success?`'
        success?
      end

      def success?
        result.success?
      end

      def valid_params
        (success? && result.output) || {}
      end

      def validation_errors
        warn 'DEPRECATED: Change `LunaPark::Validators::Dry#validation_errors` to `#errors`'
        errors
      end

      def errors
        result.errors || {}
      end

      private

      attr_reader :params

      def result
        @result ||= self.class.schema.call(params)
      end

      class << self
        def schema
          @_schema
        end

        alias validate new

        private

        def validation_schema(&block)
          @_schema = ::Dry::Validation.Params(&block)
        end
      end
    end
  end
end

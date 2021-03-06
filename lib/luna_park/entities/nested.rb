# frozen_string_literal: true

module LunaPark
  module Entities
    # add description
    class Nested
      include Extensions::Attributable
      include Extensions::Comparable
      include Extensions::ComparableDebug

      class << self
        def namespace(name, &block)
          fields_to_h       << name
          fields_comparsion << name

          namespace_class = Class.new(Nested)
          namespace_class.define_singleton_method(:name) { "Namespace:#{name}" }
          namespace_class.class_eval(&block)

          attr_reader(name)
          define_method(:"#{name}=") do |input|
            instance_variable_set(:"@#{name}", namespace_class.wrap(input))
          end
        end

        def attrs?(*args, **options)
          attrs(*args, **options.merge(predicate: true))
        end

        def attrs(*args, **options)
          names, klass, method = args.chunk { |arg| arg.is_a?(Class) }.map(&:last)
          raise 'Expected only one `Class` AND `:method`' if klass&.count != method&.count || klass && klass.count > 1

          names.each { |name| attr name, klass&.first, method&.first, **options }
        end

        def attr?(*args, **options)
          attr(*args, **options.merge(predicate: true))
        end

        def attr(name, klass = nil, method = nil, comparable: true, predicate: false)
          fields_to_h       << name
          fields_comparsion << name if comparable

          attr_reader(name)
          define_method(:"#{name}?") { send(name) ? true : false } if predicate
          return attr_writer(name) if klass.nil? && method.nil?

          define_method(:"#{name}=") do |input|
            instance_variable_set(:"@#{name}", klass.public_send(method, input))
          end
        end

        def wrap(input)
          case input
          when self then input
          when Hash then new(input)
          else raise Errors::Unwrapable, "#{self} can`t wrap #{input.class}"
          end
        end

        def fields_to_h
          @fields_to_h ||= []
        end

        def fields_comparsion
          @fields_comparsion ||= []
        end
      end

      def initialize(params = {})
        set_attributes(params)
      end

      def to_h
        self.class
            .fields_to_h
            .each_with_object({}) do |field, output|
          value = public_send(field)
          next if value.nil?

          output[field] = value_to_h(value)
        end
      end

      def inspect
        attrs = self.class.fields_to_h.map do |field|
          value = send(field)
          "@#{field}=#{value.inspect}" if value
        end
        "#<#{self.class.name} #{attrs.compact.join(' ')}>"
      end

      private

      HASHEABLE = ->(o) { o.respond_to?(:to_h) }.freeze

      def value_to_h(value)
        case value
        when Array then value.map              { |v| value_to_h(v) } # TODO: work with Array (wrap values)
        when Hash  then value.transform_values { |v| value_to_h(v) }
        when HASHEABLE then value.to_h
        else value
        end
      end

      def comparsion_attributes
        self.class.fields_comparsion
      end
    end
  end
end

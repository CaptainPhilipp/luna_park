# frozen_string_literal: true

module LunaPark
  module Extensions
    ##
    # class-level mixin
    #
    # @example
    #  class Account
    #    extend LunaPark::Extensions::Wrappable
    #
    #    attr_reader :type, :id
    #
    #    def initialize(type:, id:)
    #      @type, @id = type, id
    #    end
    #  end
    #
    #  hash = { type: 'user', id: 42 }
    #  acccount = Account.new(hash)
    #
    #  Account.new(hash)      # => #<Account type='user', id=42>
    #  Account.new(acccount)  # => raise ArgumentError
    #  Account.wrap(hash)     # => #<Account type='user', id=42>
    #  Account.wrap(acccount) # => #<Account type='user', id=42>
    #  Account.wrap(nil)      # raise 'Account can not wrap NilClass'
    #
    #  Account.wrap(account).eql?(account) # => true
    module Wrappable
      ##
      # @example
      #   class Some
      #     extend Lunapark::Extensions::Wrappable
      #     ...
      #   end
      #   obj = Some.new(foo: 'FOO')
      #   Some.wrap(obj) == obj
      #   Some.wrap(obj).equal?(obj)
      #
      #   class Account
      #     extend Lunapark::Extensions::Wrappable[Hash]
      #     ...
      #   end
      #   attrs = { type: 'user', uid: 42 }
      #   Account.wrap(attrs) == Account.new(attrs)
      #
      #   class Money
      #     extend Lunapark::Extensions::Wrappable[Hash => :from_hash]
      #     ...
      #   end
      #   attrs = { currency: 'USD', amount: 42 }
      #   Money.from_hash(attrs) == Money.wrap(attrs)
      #
      #   class Card
      #     extend Lunapark::Extensions::Wrappable[String, Integer, Float]
      #     ...
      #   end
      #   Card.wrap('42') == Card.new('42')
      #   Card.wrap(42)   == Card.new(42)
      #   Card.wrap(42.0) == Card.new(42.0)
      def self.[](*args)
        wrap_schema = {}
        wrap_schema.merge!(args.pop) if args.last.is_a?(Hash)
        args.each { |type| wrap_schema[type] = :new }
        Extender.new(wrap_schema)
      end

      def wrap(input)
        return input if input.is_a?(self)

        if block_given?
          wrapped = yield
          return wrapped if wrapped
        end

        @__wrap_schema__&.each do |klass, method|
          next unless input.is_a?(klass)

          return public_send(method, input)
        end

        raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
      end

      def inherited(child)
        child.instance_variable_set(:@__wrap_schema__, @__wrap_schema__.dup) if @__wrap_schema__
      end

      class Extender < Module
        def initialize(new_schema)
          @new_schema = new_schema
        end

        def extended(base)
          base.extend(Wrappable)
          base.instance_variable_set(:@__wrap_schema__, @new_schema)
        end
      end
    end
  end
end

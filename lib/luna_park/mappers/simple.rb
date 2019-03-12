# frozen_string_literal: true

module LunaPark
  module Mappers
    # add description
    class Simple
      class << self
        def from_rows(hashes)
          return [] if hashes.nil?

          hashes.to_a.map { |hash| from_row(hash) }
        end

        def to_rows(entities)
          return [] if entities.nil?

          entities.to_a.map { |entity| to_row(entity) }
        end

        def from_row(_hash)
          raise NotImplementedError
        end

        def to_row(_entity)
          raise NotImplementedError
        end
      end
    end
  end
end

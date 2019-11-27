# frozen_string_literal: true

module Gladwords
  # @api private
  module Types
    include ROM::Types

    def self.type(**meta)
      yield(meta).meta(meta)
    end

    ID = Types::Int

    Date = type(format: '%Y%m%d') do |format:|
      read = Types.Constructor(::Date) { |d| ::Date.strptime(d, format) }

      Types::String.meta(read: read)
    end

    Statuses = Types::Strict::String.enum(
      'UNKNOWN',
      'ENABLED',
      'PAUSED',
      'REMOVED'
    )
  end
end

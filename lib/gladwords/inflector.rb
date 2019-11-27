# frozen_string_literal: true

require 'dry/inflector'

module Gladwords
  Inflector = Dry::Inflector.new do |i|
    # This is part of ROM::Inflector's configuration
    i.plural(/people\z/i, 'people')

    i.plural(/criterion\z/i, 'criteria')
    i.singular(/criteria\z/i, 'criterion')
  end

  # Inflection mixin
  module Inflection
    def inflector
      Gladwords::Inflector
    end
  end
end

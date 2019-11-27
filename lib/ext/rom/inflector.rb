# frozen_string_literal: true

require 'rom/support/inflector'

module ROM
  remove_const('Inflector')
  Inflector = Gladwords::Inflector
end

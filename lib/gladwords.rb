# frozen_string_literal: true

require 'rom'

require_relative 'gladwords/inflector'
require_relative 'ext/rom/inflector'
require_relative 'gladwords/selector_fields_db'
require_relative 'gladwords/errors'
require_relative 'gladwords/version'
require_relative 'gladwords/gateway'
require_relative 'gladwords/relation'
require_relative 'gladwords/commands'
require_relative 'gladwords/types'

# rom-rb adapter for Google AdWords
#
# @api public
module Gladwords
  include Dry::Core::Constants
end

ROM.register_adapter(:adwords, Gladwords)

# frozen_string_literal: true

require 'gladwords/commands/core'

module Gladwords
  module Commands
    # Update command
    # This command uses the SET operator to update entities in AdWords
    # @api public
    class Update < ROM::Commands::Update
      include Core

      adapter :adwords
      adwords_operator :SET
    end
  end
end

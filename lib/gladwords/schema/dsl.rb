# frozen_string_literal: true

module Gladwords
  class Schema < ROM::Schema
    # Specialized schema DSL with Adwords-specific features
    #
    # @api public
    class DSL < ROM::Schema::DSL
      attr_reader :shitlist_list

      def shitlist(*attr_names)
        @shitlist_list ||= []
        @shitlist_list += attr_names
      end

      private

      # Return schema opts
      # @return [Hash]
      #
      # @api private
      def opts
        opts = super
        { **opts, shitlist: shitlist_list || [] }
      end
    end
  end
end

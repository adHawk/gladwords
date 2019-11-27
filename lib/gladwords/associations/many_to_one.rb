# frozen_string_literal: true

require 'rom/associations/many_to_one'

module Gladwords
  module Associations
    # A class which represents a many to one relationship (i.e. belongs_to)
    #
    # @api private
    class ManyToOne < ROM::Associations::ManyToOne
      def call(target:)
        target
      end

      def preload(target, loaded)
        target_pks = loaded.pluck(:campaign_id)

        target.where(target.schema.primary_key_name => target_pks)
      end
    end
  end
end

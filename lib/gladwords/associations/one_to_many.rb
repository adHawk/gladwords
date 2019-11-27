# frozen_string_literal: true

require 'rom/associations/one_to_many'

module Gladwords
  module Associations
    # @api private
    class OneToMany < ROM::Associations::OneToMany
      def call(target:)
        target
      end

      def preload(target, loaded)
        target_pks = loaded.pluck(:id)
        target.where(foreign_key => target_pks)
      end
    end
  end
end

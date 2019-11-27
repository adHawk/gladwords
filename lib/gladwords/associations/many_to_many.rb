# frozen_string_literal: true

require 'rom/associations/many_to_many'

module Gladwords
  module Associations
    # Many to many implementation
    class ManyToMany < ROM::Associations::ManyToMany
      def call(target:)
        target
      end

      def preload(target, _loaded)
        target
      end
    end
  end
end

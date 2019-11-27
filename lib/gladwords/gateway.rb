# frozen_string_literal: true

require 'rom/gateway'

module Gladwords
  # AdWords gateway
  #
  # @api public
  class Gateway < ROM::Gateway
    class DatasetMappingError < StandardError; end
    include Inflection

    attr_reader :datasets, :client

    defines :datasets_mapping

    datasets_mapping(
      ad_group_criteria: :AdGroupCriterionService
    )

    def initialize(config)
      @client = config.fetch(:client)
    end

    def dataset(name)
      service_name = self.class.datasets_mapping.fetch(name) do
        inflector.camelize(inflector.singularize(name)) + 'Service'
      end

      client.service(service_name.to_sym, :v201809)
    rescue StandardError => e
      raise DatasetMappingError,
            "Could not map #{name} to an Adwords service. \n" \
            'Please register it by adding it to the ' \
            "Gladwords::Gateway.dataset_mappings config (Original: #{e.message}). \n" \
            '  i.e. Gladwords::Gateway.dataset_mappings[:customers] = :CustomerService'
    end

    def dataset?(name)
      self.class.datasets_mapping.key?(name.to_sym)
    end

    def service_registry(name)
      srv = dataset(name.to_sym)
      srv.send(:get_service_registry)
    end
  end
end

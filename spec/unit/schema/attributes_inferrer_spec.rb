# frozen_string_literal: true

require 'adwords_api/v201809/campaign_service_registry'

module Gladwords
  RSpec.describe Schema::AttributesInferrer do
    let(:schema) { double(name: :campaigns, options: { shitlist: [] }) }
    let(:registry) { AdwordsApi::V201809::CampaignService::CampaignServiceRegistry }
    let(:gateway) { double(service_registry: registry) }

    describe '#call' do
      declarations = {
        String => %i[
          name
          status
          serving_status
          start_date
          end_date
          ad_serving_optimization_status
          advertising_channel_type
          advertising_channel_sub_type
          campaign_trial_type
          tracking_url_template
          final_url_suffix
        ],
        Integer => %i[id base_campaign_id campaign_group_id]
      }

      declarations.each do |primitive, fields|
        it "maps to #{primitive.name}", skip: fields.delete(skip: true) do
          types, _missing = subject.call(schema, gateway)
          attrs = types.select { |a| a.type.primitive == primitive }

          expect(attrs.map(&:name)).to match_array(fields)
        end
      end

      it 'maps nested types to hashes' do
        types, _missing = subject.call(schema, gateway)
        hash_field = types.find { |t| t.name == :budget }
        member_types = hash_field.type.options[:member_types]

        aggregate_failures do
          expect(member_types[:budget_id].primitive).to eq(Integer)
          expect(member_types[:name].primitive).to eq(String)
        end
      end

      it 'includes read types for known nested hashes' do
        types, _missing = subject.call(schema, gateway)
        hash_field = types.find { |t| t.name == :budget }

        read_type = hash_field.meta[:read]

        expect(read_type).to be_a(Dry::Types::Constructor)
      end

      it 'removes shitlist attributes from schema' do
        allow(schema).to receive(:options).and_return(shitlist: [:end_date])
        types, _missing = subject.call(schema, gateway)

        expect(types.find { |t| t.name == :end_date }).to be_nil
      end

      it 'created enumerated types' do
        types, _missing = subject.call(schema, gateway)
        status = types.find { |t| t.name == :status }
        type = status.type

        expect(type).to be_a(Dry::Types::Enum)
        expect(type.options).to eql(values: %w[UNKNOWN ENABLED PAUSED REMOVED])
      end

      it 'creates enumerated type arrays' do
        types, _missing = subject.call(schema, gateway)
        status = types.find { |t| t.name == :conversion_optimizer_eligibility }
        type = status.type.member_types[:rejection_reasons].type

        expect(type).to be_a(Dry::Types::Array)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.shared_context :campaigns do
  let(:client) { gimme_adwords }
  let(:configuration) do
    ROM::Configuration.new(:adwords, client: client) do |config|
      config.relation(:campaigns) do
        auto_struct(true)
        auto_map(true)

        schema(infer: true) do
          attribute :id, Gladwords::Types::ID

          primary_key :id

          associations do
            has_many :ad_groups, combine_key: :campaign_id
            has_many :ad_group_ads, through: :ad_groups
            # , combine_key: :ad_group_id, foreign_key: :base_campaign_id
          end
        end
      end

      config.relation(:ad_groups) do
        auto_struct(true)
        auto_map(true)

        schema(infer: true) do
          attribute :id, Gladwords::Types::ID

          primary_key :id

          associations do
            belongs_to :campaign, combine_key: :id
            has_many :ad_group_ads, combine_key: :ad_group_id
          end
        end
      end

      config.relation(:ad_group_ads) do
        auto_struct(true)
        auto_map(true)

        schema(infer: true) do
          associations do
            belongs_to :ad_group
            has_one :campaign, through: :ad_groups
          end
        end
      end
    end
  end
  let(:rom) { ROM.container(configuration) }
  let(:campaign_service) { rom.gateways[:default].dataset(:campaigns) }
  let(:campaigns) { rom.relations[:campaigns] }
end

# frozen_string_literal: true

RSpec.describe Gladwords::Relation do
  include_context 'campaigns'

  subject { campaigns }

  describe '#by_pk' do
    it 'loads the resource by id and limits the result' do
      new_scope = subject.by_pk('123')
      predicates = new_scope.options.dig(:selector, :predicates)
      paging = new_scope.options.dig(:selector, :paging)

      expect(predicates).to eql([{ field: 'Id', operator: 'IN', values: ['123'] }])
      expect(paging).to eql(number_results: 1)
    end
  end

  describe '#where' do
    it 'chains where clauses' do
      old_scope = subject.select(:id, :name).where(id: '123')
      new_scope = old_scope.where(name: 'TestName')
      expected = [{ field: 'Id',   operator: 'IN', values: ['123'] },
                  { field: 'Name', operator: 'IN', values: ['TestName'] }]
      predicates = new_scope.options.dig(:selector, :predicates)

      expect(predicates).to match_array(expected)
    end

    it 'de-duplicates where clauses' do
      old_scope = subject.select(:id, :name).where(id: '123')
      new_scope = old_scope.where(id: '123')
      expected = [{ field: 'Id', operator: 'IN', values: ['123'] }]
      predicates = new_scope.options.dig(:selector, :predicates)

      expect(predicates).to match_array(expected)
    end
  end

  describe '#total_count' do
    it 'shows the total_count' do
      scope = subject.select(:id, :name).where(name: 'Test Campaign 2')

      expect(scope.total_count).to eq 1
    end
  end

  describe '#offset' do
    it 'offsets the start_index' do
      scope = subject.offset(10)

      expect(scope.options.dig(:selector, :paging, :start_index)).to eq 10
    end
  end

  describe '#limit' do
    it 'sets the paging[:number_results]' do
      scope = subject.limit(3)

      expect(scope.options.dig(:selector, :paging, :number_results)).to eq 3
    end
  end

  describe '#select' do
    it 'camelcases the fields' do
      scope = subject.select(:base_campaign_id, :name)
      fields = scope.options.dig(:selector, :fields)

      expect(fields).to contain_exactly 'BaseCampaignId', 'Name'
    end

    it 'only selects unique fields' do
      scope = subject.select(:name).select(:name)
      fields = scope.options.dig(:selector, :fields)

      expect(fields).to contain_exactly 'Name'
    end

    it 'limits requested fields when using #select' do
      repo = Class.new(ROM::Repository[:campaigns]).new(rom)
      result = repo.campaigns.select(:name).limit(1).one

      expect(result.to_h.keys).to contain_exactly(:name)
    end
  end

  describe '#pluck' do
    it 'returns an array of the ids' do
      ids = subject.pluck(:id).call

      expect(ids).not_to be_empty
      expect(ids).to all be_a(Integer)
    end

    it 'only requests the plucked field' do
      expect(campaign_service)
        .to receive(:get)
        .with(a_hash_including(fields: ['Id']))
        .and_return({})

      scope = subject.pluck(:id)

      expect(scope.options.dig(:selector, :fields)).to eql(['Id'])
      scope.call
    end
  end

  it 'by default selects all selectable fields' do
    repo = Class.new(ROM::Repository[:campaigns]).new(rom)
    scope = repo.campaigns.where(name: 'Test Campaign 2')
    result = scope.call

    expected = {
      id: 1_338_164_832,
      status: 'ENABLED',
      serving_status: 'SERVING',
      ad_serving_optimization_status: 'OPTIMIZE',
      advertising_channel_type: 'SEARCH',
      advertising_channel_sub_type: nil,
      campaign_trial_type: 'BASE',
      campaign_group_id: nil,
      name: 'Test Campaign 2',
      start_date: '20180329',
      end_date: '20371230',
      universal_app_campaign_info: nil,
      final_url_suffix: nil,
      budget: {
        budget_id: 1_391_080_779,
        name: 'Test Campaign 2',
        amount: a_hash_including(micro_amount: 999_000_000),
        delivery_method: 'STANDARD',
        reference_count: 1,
        is_explicitly_shared: false,
        status: 'ENABLED'
      },
      conversion_optimizer_eligibility: {
        eligible: false,
        rejection_reasons: ['NOT_ENOUGH_CONVERSIONS']
      },
      frequency_cap: nil,
      settings: [{
        setting_type: 'GeoTargetTypeSetting',
        positive_geo_target_type: 'LOCATION_OF_PRESENCE',
        negative_geo_target_type: 'DONT_CARE',
        xsi_type: 'GeoTargetTypeSetting'
      }],
      network_setting: {
        target_google_search: true,
        target_search_network: true,
        target_content_network: false,
        target_partner_search_network: false
      },
      labels: [],
      bidding_strategy_configuration: {
        bidding_strategy_id: nil,
        bidding_strategy_name: nil,
        bidding_strategy_type: 'MANUAL_CPC',
        bidding_strategy_source: nil,
        bidding_scheme: {
          bidding_scheme_type: 'ManualCpcBiddingScheme',
          enhanced_cpc_enabled: false,
          xsi_type: 'ManualCpcBiddingScheme'
        },
        bids: [],
        target_roas_override: nil
      },
      base_campaign_id: 1_338_164_832,
      forward_compatibility_map: [],
      tracking_url_template: nil,
      url_custom_parameters: nil,
      vanity_pharma: nil,
      selective_optimization: nil
    }

    entries = result.map(&:to_h)

    expect(entries.first).to match(expected)
    expect(entries).to contain_exactly(expected)
  end

  describe '#request' do
    it 'raises when the method does not exist' do
      expect { subject.request(:bad_method) }
        .to raise_error described_class::InvalidRequestMethodError
    end
  end
end

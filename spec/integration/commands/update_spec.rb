# frozen_string_literal: true

require 'securerandom'

RSpec.describe Gladwords::Commands::Update do
  include_context :campaigns

  let(:service) { campaign_service }
  let(:relation) { campaigns }

  subject(:command) do
    relation.command(:update)
  end

  it 'updates the campaign name' do
    campaign = relation.select(:id, :name).first
    name = SecureRandom.hex

    subject.call(id: campaign[:id], name: name)

    campaign = relation.select(:id, :name).first
    expect(campaign[:name]).to eq name
  end
end

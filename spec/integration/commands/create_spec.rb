# frozen_string_literal: true

RSpec.describe Gladwords::Commands::Create do
  include_context :labels

  let(:service) { label_service }
  let(:relation) { labels }

  subject(:command) do
    relation.command(:create)
  end

  it 'creates a label' do
    name = SecureRandom.hex

    subject.call(name: name, xsi_type: 'TextLabel')

    rel = relation.where(label_name: name)

    expect(rel.first[:name]).to eq name

    rel.command(:delete).call
  end
end

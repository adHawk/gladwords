# frozen_string_literal: true

RSpec.describe Gladwords::Commands::Delete do
  include_context 'labels'

  subject(:command) do
    relation.command(:delete)
  end

  let(:service) { label_service }
  let(:relation) { labels }

  it 'deletes the label' do
    label = relation.command(:create).call(name: SecureRandom.hex, xsi_type: 'TextLabel')

    rel = relation.where(label_id: label.id).limit(1)
    expect(rel.first[:status]).to eq 'ENABLED'

    delete_command = rel.command(:delete)
    delete_command.call

    expect(rel.with({}).call.first[:status]).to eq 'REMOVED'
  end

  it 'deletes multiple labels' do
    label, label2 = relation.command(:create, result: :many).call(
      [
        { name: SecureRandom.hex, xsi_type: 'TextLabel' },
        { name: SecureRandom.hex, xsi_type: 'TextLabel' }
      ]
    )

    rel = relation.where(label_id: [label.id, label2.id])
                  .limit(2)

    delete_command = rel.command(:delete)
    delete_command.call

    labels = rel.with({}).call

    expect(labels.count).to eq 2

    labels.each do |lab|
      expect(lab[:status]).to eq 'REMOVED'
    end
  end
end

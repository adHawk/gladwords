# frozen_string_literal: true

RSpec.describe Gladwords::Commands::Delete do
  include_context :labels

  let(:service) { label_service }
  let(:relation) { labels }

  subject(:command) do
    relation.command(:delete)
  end

  before do
    allow(service).to receive(:get).and_return(entries: [{ id: '1' }])
    allow(service).to receive(:mutate).and_return(value: [{ id: '1' }])
  end

  it 'mutates the service with the correct operations' do
    expect(service).to receive(:mutate).with(
      [
        {
          operator: 'REMOVE',
          operand: { id: '1' }
        }
      ]
    )

    rel = relation.where(id: 1)
    delete_command = rel.command(:delete)
    delete_command.call
  end
end

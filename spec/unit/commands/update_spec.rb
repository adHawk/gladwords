# frozen_string_literal: true

require 'securerandom'

RSpec.describe Gladwords::Commands::Update do
  include_context :campaigns

  let(:service) { campaign_service }
  let(:relation) { campaigns }

  subject(:command) do
    relation.command(:update)
  end

  context 'when provided a single tuple' do
    before do
      allow(service).to receive(:mutate).and_return(
        value: [{ name: 'updated name', id: '1', end_date: '01012017' }]
      )
    end

    it 'mutates the service with the correct operations' do
      expect(service).to receive(:mutate).with(
        [
          {
            operator: 'SET',
            operand: {
              name: 'updated name',
              id: '1'
            }
          }
        ]
      )

      subject.call(name: 'updated name', id: '1')
    end

    it 'returns a struct' do
      result = subject.call(name: 'updated name', id: '1')

      expect(result).to be_a(Gladwords::Struct::Campaign)
      expect(result.id).to eq '1'
      expect(result.name).to eq 'updated name'
    end
  end

  context 'when provided multiple tuples' do
    subject(:command) do
      relation.command(:update, result: :many)
    end

    before do
      allow(service).to(
        receive(:mutate).and_return(
          value: [
            { name: 'updated name', id: '1', end_date: '01012017' },
            { name: 'updated name 2', id: '2', end_date: '01012018' }
          ]
        )
      )
    end

    it 'mutates the service with the correct operations' do
      expect(service).to receive(:mutate).with(
        [
          {
            operator: 'SET',
            operand: {
              name: 'updated name',
              id: '1'
            }
          },
          {
            operator: 'SET',
            operand: {
              name: 'updated name 2',
              id: '2'
            }
          }
        ]
      )

      subject.call([{ name: 'updated name', id: '1' }, { name: 'updated name 2', id: '2' }])
    end

    it 'returns an array of structs' do
      result = subject.call(
        [{ name: 'updated name', id: '1' }, { name: 'updated name 2', id: '2' }]
      )

      expect(result.count).to eq 2

      expect(result).to all be_a(Gladwords::Struct::Campaign)
    end
  end
end

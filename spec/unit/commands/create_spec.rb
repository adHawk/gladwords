# frozen_string_literal: true

RSpec.describe Gladwords::Commands::Create do
  include_context :labels

  let(:service) { label_service }
  let(:relation) { labels }

  subject(:command) do
    relation.command(:create)
  end

  context 'when provided a single tuple' do
    before do
      allow(service).to receive(:mutate).and_return(value: [{ name: 'test', id: '1' }])
    end

    it 'mutates the service with the correct operations' do
      expect(service).to receive(:mutate).with(
        [
          {
            operator: 'ADD',
            operand: {
              name: 'test',
              id: '1'
            }
          }
        ]
      )

      subject.call(name: 'test', id: '1')
    end

    it 'returns a struct' do
      result = subject.call(name: 'test', id: '1')

      expect(result).to be_a(Gladwords::Struct::Label)
      expect(result.id).to eq '1'
      expect(result.name).to eq 'test'
    end
  end

  context 'when provided multiple tuples' do
    subject(:command) do
      relation.command(:create, result: :many)
    end

    before do
      allow(service).to(
        receive(:mutate).and_return(value: [{ name: 'foo', id: '1' }, { name: 'bar', id: '2' }])
      )
    end

    it 'mutates the service with the correct operations' do
      expect(service).to receive(:mutate).with(
        [
          {
            operator: 'ADD',
            operand: {
              name: 'foo',
              id: '1'
            }
          },
          {
            operator: 'ADD',
            operand: {
              name: 'bar',
              id: '2'
            }
          }
        ]
      )

      subject.call([{ name: 'foo', id: '1' }, { name: 'bar', id: '2' }])
    end

    it 'returns an array of structs' do
      result = subject.call([{ name: 'foo', id: '1' }, { name: 'bar', id: '2' }])

      expect(result.count).to eq 2

      expect(result).to all be_a(Gladwords::Struct::Label)
    end
  end
end

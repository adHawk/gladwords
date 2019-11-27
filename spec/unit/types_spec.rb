# frozen_string_literal: true

module Gladwords
  RSpec.describe Types do
    describe Types::Date do
      describe '#read' do
        subject(:read_type) { described_class.meta[:read] }

        let(:format) { described_class.meta[:format] }
        let(:date_string) { '20181231' }

        it 'parses to a Ruby Date instance' do
          expect(read_type[date_string]).to be_a ::Date
        end

        it 'includes the correct format in the metadata' do
          expect(read_type[date_string].strftime(format)).to eq date_string
        end
      end
    end

    describe Types::Statuses do
      subject(:statuses) { described_class.type }

      it 'disallows invalid strings' do
        expect { statuses['ITYPOED'] }.to raise_error Dry::Types::ConstraintError
      end

      %w[
        UNKNOWN
        ENABLED
        PAUSED
        REMOVED
      ].each do |status|
        it "allows the \"#{status}\" status" do
          expect(statuses[status]).to eq status
        end
      end
    end

    describe Types::ID do
      subject(:id) { described_class }

      it 'maps to an Integer primitive' do
        expect(id.primitive).to be Integer
      end
    end
  end
end

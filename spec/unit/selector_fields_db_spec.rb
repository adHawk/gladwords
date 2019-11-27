# frozen_string_literal: true

RSpec.describe Gladwords do
  describe '.selector_fields_db' do
    %i[v201806 v201809].each do |version|
      let(:db) { described_class.selector_fields_db(version) }

      let(:field_entries) { db.values.map(&:values).flatten }

      it 'has the correct number of services' do
        expect(db.keys.length).to be >= 43
      end

      it 'keys services by method' do
        expect(db[:campaigns]).to have_key(:get)
      end

      it 'includes the field name for each item' do
        field_entries = db.values.map(&:values).flatten

        expect(field_entries).to all have_key(:field)
      end

      it 'includes the filterable key for each item' do
        expect(field_entries).to all have_key(:filterable)
      end
    end
  end
end

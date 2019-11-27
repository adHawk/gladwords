# frozen_string_literal: true

RSpec.describe Gladwords::Inflector do
  it 'correctly pluralizes criterion' do
    expect(described_class.pluralize('criterion')).to eq 'criteria'
  end

  it 'correctly singularizes criteria' do
    expect(described_class.singularize('criteria')).to eq 'criterion'
  end
end

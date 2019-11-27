# frozen_string_literal: true

RSpec.shared_context 'labels' do
  let(:client) { gimme_adwords }
  let(:configuration) do
    ROM::Configuration.new(:adwords, client: client) do |config|
      config.relation(:labels) do
        auto_struct(true)

        schema(infer: true)
      end
    end
  end
  let(:rom) { ROM.container(configuration) }
  let(:label_service) { rom.gateways[:default].dataset(:labels) }
  let(:labels) { rom.relations[:labels] }
end

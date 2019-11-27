# frozen_string_literal: true

module Gladwords
  RSpec.describe Relation::AssociationMethods do
    include_context 'campaigns'

    context 'when the relation is one-to-many' do
      subject { campaigns }

      describe '#join' do
        let(:campaign_id) { 1_338_164_832 }
        let(:filtered_relation) { subject.select(:id).where(id: campaign_id).join(:ad_groups) }

        it 'filters the target relation' do
          returned_ids = filtered_relation.call.flat_map(&:ad_groups).map(&:campaign_id)

          expect(returned_ids).to all eq(campaign_id)
        end

        it 'returns the filtered combined relationship' do
          ad_groups = filtered_relation.ad_groups.call

          aggregate_failures do
            expect(ad_groups).to all be_a(Gladwords::Struct::AdGroup)
            expect(ad_groups.pluck(:campaign_id)).to all eq(campaign_id)
          end
        end

        it 'can query on the combined node' do
          scope = filtered_relation.node(:ad_groups) { |n| n.select(:campaign_id) }
          ad_group = scope.one.ad_groups.first
          expect(ad_group.to_h).to eql(campaign_id: campaign_id)
        end
      end
    end

    context 'when the relation is many-to-one' do
      subject { rom.relations[:ad_groups] }

      describe '#combine' do
        let(:campaign_id) { 1_338_164_832 }
        let(:filtered_relation) { subject.combine(:campaign) }

        it 'filters the target relation' do
          scope = filtered_relation.where(campaign_id: campaign_id)
          ad_group = scope.limit(1).call.one
          expect(ad_group.campaign.id).to eql(campaign_id)
        end

        it 'can query on the combined node' do
          scope = filtered_relation.where(campaign_id: campaign_id)
          scope = scope.node(:campaign) { |n| n.select(:id) }
          campaign = scope.call.one.campaign
          expect(campaign.to_h).to eql(id: campaign_id)
        end
      end
    end

    context 'when the relation is has-many through' do
      subject { campaigns }

      describe '#combine' do
        let(:campaign_id) { 1_338_164_832 }

        context 'when the combine is nested' do
          let(:filtered_relation) { subject.combine(ad_groups: [:ad_group_ads]) }

          it 'includes the nested has_many through' do
            scope = filtered_relation.where(campaign_id: campaign_id).one
            ads = scope.ad_groups.flat_map(&:ad_group_ads)
            expect(ads).not_to be_empty
            expect(ads.map(&:base_campaign_id)).to all eq(campaign_id)
          end
        end

        context 'when the combine is direct' do
          let(:filtered_relation) { subject.combine(:ad_group_ads) }

          it 'includes the nested has_many through' do
            pending 'Combine is not working for direct has many through'
            scope = filtered_relation.where(campaign_id: campaign_id).one

            ads = scope.ad_group_ads
            expect(ads).not_to be_empty
            expect(ads.map(&:base_campaign_id)).to all eq(campaign_id)
          end
        end
      end
    end
  end
end

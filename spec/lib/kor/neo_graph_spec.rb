require "rails_helper"

RSpec.describe Kor::NeoGraph, skip: 'not integrated within the dependencies yet' do
  it "should create nodes" do
    admin = FactoryGirl.create :admin
    graph = described_class.new(admin)

    mona_lisa = FactoryGirl.create :mona_lisa
    graph.store_entity mona_lisa

    der_schrei = FactoryGirl.create :der_schrei
    graph.store_entity der_schrei

    # node = graph.find(mona_lisa)
    # expect(node["entity_id"]).to eq(mona_lisa.id)

    # binding.pry
  end

  it 'should rollback transactions' do
    admin = FactoryGirl.create :admin
    mona_lisa = FactoryGirl.create :mona_lisa
    graph = described_class.new(admin)

    expect {
      graph.transaction do
        expect {
          graph.store_entity mona_lisa
        }.to change { graph.node_count }.by(1)
      end
    }.not_to change { graph.node_count }
  end
end
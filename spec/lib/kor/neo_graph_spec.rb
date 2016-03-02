require "rails_helper"

describe Kor::NeoGraph do

  it "should create nodes" do
    admin = FactoryGirl.create :admin
    graph = described_class.new(admin)

    mona_lisa = FactoryGirl.create :mona_lisa
    graph.store mona_lisa

    der_schrei = FactoryGirl.create :der_schrei
    graph.store der_schrei

    # node = graph.find(mona_lisa)
    # expect(node["entity_id"]).to eq(mona_lisa.id)

    # binding.pry
  end

end
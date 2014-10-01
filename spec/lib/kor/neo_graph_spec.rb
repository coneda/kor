require "rails_helper"

describe Kor::NeoGraph do

  before :each do
    base_dir = "/opt/neo4j-community-2.1.4"
    system "#{base_dir}/bin/neo4j stop"
    system "rm -rf #{base_dir}/data/*"
    system "#{base_dir}/bin/neo4j start"
  end

  it "should create and retrieve a node" do
    admin = FactoryGirl.create :admin
    graph = described_class.new(admin)

    mona_lisa = FactoryGirl.create :mona_lisa
    node = graph.create mona_lisa
    expect(node).to match(/\/db\/data\/node\/0$/)

    der_schrei = FactoryGirl.create :der_schrei, :kind => mona_lisa.kind
    node = graph.create der_schrei
    expect(node).to match(/\/db\/data\/node\/1$/)

    expect(graph.find_id_by_uuid mona_lisa.uuid).to eq(0)
    expect(graph.find_id_by_uuid der_schrei.uuid).to eq(1)


    node = graph.find(mona_lisa)
    # expect(node["entity_id"]).to eq(mona_lisa.id)

    debugger
    x = 12
  end

end
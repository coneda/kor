require 'spec_helper'

describe Kor::Graph do

  it "should not find paths of length 0" do
    FactoryGirl.create :admin

    graph = described_class.new(:user => User.admin)
    expect(graph.find_paths([])).to eq([])

    FactoryGirl.create :has_created
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo
    Relationship.relate_and_save leonardo, "has created", mona_lisa 

    expect(graph.find_paths([])).to eq([])
  end

  it "should not find incomplete paths" do
    FactoryGirl.create :admin

    graph = described_class.new(:user => User.admin)
    expect(graph.find_paths([{}, {}])).to eq([])

    FactoryGirl.create :has_created
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo
    Relationship.relate_and_save leonardo, "has created", mona_lisa 

    expect(graph.find_paths([{}, {}])).to eq([])
  end

  it "should find paths of length 1" do
    FactoryGirl.create :admin

    graph = described_class.new(:user => User.admin)
    expect(graph.find_paths([{}, {}, {}])).to eq([])

    has_created = FactoryGirl.create :has_created
    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo
    the_last_supper = FactoryGirl.create :the_last_supper
    r = Relationship.relate_and_save leonardo, "has created", mona_lisa
    r = Relationship.relate_and_save leonardo, "has created", the_last_supper 

    results = graph.find_paths([{}, {}, {}])
    expect(results.size).to eq(4)

    # expect
    p results
    debugger
    expect(results[0][0]).to include('id' => leonardo.id)
    expect(results[0][1]).to include(
      'relation_id' => has_created.id,
      'reverse' => false
    )
    expect(results[0][2]).to include('id' => mona_lisa.id)
  #     [
  #       {'id' => mona_lisa.id, 'kind_id'},
  #       {'id' => has_created.id, 'name' => 'was created by'},
  #       {'id' => leonardo.id}],
  #     ],[
  #       {'id' => the_last_supper.id},
  #       {'id' => has_created.id, 'name' => 'was created by'},
  #       {'id' => leonardo.id}
  #     ],
  #     [{'id' => leonardo.id}, {'id' => has_created.id, 'name' => 'has created'}, {'id' => the_last_supper.id}],
  #     [{'id' => leonardo.id}, {'id' => has_created.id, 'name' => 'has created'}, {'id' => mona_lisa.id}]
  #   ])
  end

  it "should find paths of length 3"
  it "should find paths of length 3 with only authorized parts"

end
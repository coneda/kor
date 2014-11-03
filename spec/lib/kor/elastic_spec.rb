require 'spec_helper'

describe Kor::Elastic, :elastic => true do

  before :each do
    @admins = FactoryGirl.create :admins
    @admin = FactoryGirl.create :admin, :groups => [@admins]
    @default = FactoryGirl.create :default
    Grant.create(:collection => @default, :credential => @admins, :policy => :view)

    @elastic = described_class.new(@admin)

    @media = FactoryGirl.create :media
    @locations = FactoryGirl.create :locations
    @united_kingdom = FactoryGirl.create :united_kingdom, :tag_list => ["coast", "english language", "beer"]
    @united_states = FactoryGirl.create :united_states, :tag_list => ["coast", "english language"]
    
    described_class.index_all
  end

  it "should be enabled only when configuration for elasticsearch is present" do
    expect(described_class.enabled?).to be_true

    allow(described_class).to receive(:config).and_return(nil)
    expect(described_class.enabled?).to be_false

    allow(described_class).to receive(:config).and_return({})
    expect(described_class.enabled?).to be_false    
  end

  it "should index an entity" do
    allow(described_class).to receive(:enabled?).and_return(false)

    @works = FactoryGirl.create :works
    @landscape = FactoryGirl.create :landscape

    allow(described_class).to receive(:enabled?).and_call_original    

    expect {
      expect(described_class.index(@landscape).first).to eq(201)
      expect(described_class.refresh.first).to eq(200)
    }.to change{@elastic.count}.by(1)
  end

  it "should search with a full token" do
    results = @elastic.search(:query => "kingdom")
    expect(results.records).to eq([@united_kingdom])

    results = @elastic.search(:query => "\"united kingdom\"")
    expect(results.records).to eq([@united_kingdom])
  end

  it "should search with partial terms" do
    results = @elastic.search(:query => "king")
    expect(results.records).to eq([@united_kingdom])

    results = @elastic.search(:query => "gdom")
    expect(results.records).to eq([@united_kingdom])

    @works = FactoryGirl.create :works
    @landscape = FactoryGirl.create :landscape
    described_class.index_all

    results = @elastic.search(:query => "dscap")
    expect(results.records).to eq([@landscape])
  end

  it "should search with 1 tag" do
    results = @elastic.search(:tags => ["coast"])
    expect(results.records.size).to eq(2)
  end

  it "should search with 2 tags" do
    results = @elastic.search(:tags => ["coast", "beer"])
    expect(results.records).to eq([@united_kingdom])
  end

  it "should search with 2 tags with 2 words and two hits" do
    results = @elastic.search(:tags => ["coast", "english language"])
    expect(results.records.size).to eq(2)
  end

  it "should search with 2 tags with 2 words and one hit otherwayround" do
    results = @elastic.search(:tags => ["beer", "english language"])
    expect(results.records).to eq([@united_kingdom])
  end

  it "should search within synonyms" do
    @people = FactoryGirl.create :people
    @works = FactoryGirl.create :works
    @landscape = FactoryGirl.create :landscape, :synonyms => ["Tree on plane", "Nice Tree"]
    @jack = FactoryGirl.create :jack, :synonyms => ["The Oak", "Tree on plane"]
    
    described_class.index_all

    # This is very nasty, however, there is no better workaround at the moment:
    # https://github.com/elasticsearch/elasticsearch/issues/1063
    # sleep 2

    # puts @elastic.search(:query => "\"tree on plane\"").inspect

    results = @elastic.search(:query => "\"tree on plane\"")
    expect(results.records.size).to eq(2)

    results = @elastic.search(:query => "\"tree on plane\"", :kind_id => @people.id)
    expect(results.records).to eq([@jack])

    results = @elastic.search(:query => "\"tree on plane\"", :kind_id => @works.id)
    expect(results.records).to eq([@landscape])

    @is_related_to = FactoryGirl.create :relation
    Relationship.relate_once_and_save(@landscape, "is related to", @jack)
    described_class.index_all :full => true

    results = @elastic.search(:query => ["\"tree on plane\"", "Oak"])
    expect(results.records).to include(@jack, @landscape)

    results = @elastic.search(:query => ["\"tree on plane\"", "Jack"])
    expect(results.records).to include(@jack, @landscape)

    results = @elastic.search(:query => ["\"tree on plane\"", "Jack"], :kind_id => @people.id)
    expect(results.records).to eq([@jack])
  end

  it "should paginate entities when there are more than 10 results" do
    @works = FactoryGirl.create :works
    11.times do |i|
      FactoryGirl.create :landscape, :name => "Auferstehung #{i}"
    end
    described_class.index_all

    results = @elastic.search(:query => "Auferst")
    expect(results.total).to eq(11)
    expect(results.records.size).to eq(10)
  end

  it "should filter by collection" do
    @private = FactoryGirl.create :private
    @united_kingdom.update_attributes :collection => @private
    described_class.index_all

    results = @elastic.search(:query => "english")
    expect(results.records).to eq([@united_states])
  end

  it "should filter by collection and kind" do
    @private = FactoryGirl.create :private
    @united_kingdom.update_attributes :collection => @private
    @people = FactoryGirl.create :people
    @jack = FactoryGirl.create :jack, :synonyms => ["The Oak", "Tree on plane"]
    described_class.index_all

    results = @elastic.search(:kind_id => @people.id)
    expect(results.records).to eq([@jack])

    Grant.create(:collection => @private, :credential => @admins, :policy => :view)

    results = @elastic.search(:kind_id => @locations.id, :collection_id => @default.id)
    expect(results.records).to eq([@united_states])

    results = @elastic.search(:kind_id => @people.id, :collection_id => @default.id)
    expect(results.records).to eq([@jack])
  end

  it "should serch in the comment with low relevance" do
    @united_kingdom.update_attributes :comment => "United States"
    @united_states.update_attributes :comment => "United Kingdom"
    described_class.index_all

    results = @elastic.search(:query => "states")
    expect(results.records).to eq([@united_states, @united_kingdom])

    results = @elastic.search(:query => "kingdom")
    expect(results.records).to eq([@united_kingdom, @united_states])
  end

  it "should serch in the properties with low relevance" do
    @united_kingdom.update_attributes :properties => [{"label" => "label", "value" => "value"}]
    @united_states.update_attributes :properties => [{"label" => "value", "value" => "label"}]
    described_class.index_all

    results = @elastic.search(:query => "label")
    expect(results.records).to eq([@united_states, @united_kingdom])

    results = @elastic.search(:query => "value")
    expect(results.records).to eq([@united_kingdom, @united_states])
  end

  it "should serch in the display name with low relevance" do
    @united_kingdom.update_attributes :distinct_name => "states"
    @united_states.update_attributes :distinct_name => "kingdom"
    described_class.index_all

    results = @elastic.search(:query => "states")
    expect(results.records).to eq([@united_states, @united_kingdom])

    results = @elastic.search(:query => "kingdom")
    expect(results.records).to eq([@united_kingdom, @united_states])
  end

  it "should serch by uuid and id" do
    results = @elastic.search(:query => @united_states.uuid)
    expect(results.records).to eq([@united_states])
  end

  it "should search for special characters and do folding" do
    @people = FactoryGirl.create :people
    @klaus_mueller = FactoryGirl.create :jack, :name => "Klaus Müller"
    described_class.index_all

    results = @elastic.search(:query => "Müller")
    expect(results.records).to eq([@klaus_mueller])

    results = @elastic.search(:query => "ülle")
    expect(results.records).to eq([@klaus_mueller])

    results = @elastic.search(:query => "muller")
    expect(results.records).to eq([@klaus_mueller])

    results = @elastic.search(:query => "Üller")
    expect(results.records).to eq([@klaus_mueller])

    results = @elastic.search(:query => "Uller")
    expect(results.records).to eq([@klaus_mueller])

    results = @elastic.search(:query => "Mûller")
    expect(results.records).to eq([@klaus_mueller])
  end

  it "should not index media" do
    expect {
      FactoryGirl.create :picture
      described_class.index_all
    }.not_to change{@elastic.search.total}
  end

  it "should search within related entities with special characters" do
    @people = FactoryGirl.create :people
    @works = FactoryGirl.create :works
    @landscape = FactoryGirl.create :landscape
    @jack = FactoryGirl.create :jack, :name => "Jäck"
    @is_related_to = FactoryGirl.create :relation
    Relationship.relate_once_and_save(@landscape, "is related to", @jack)
    described_class.index_all :full => true

    results = @elastic.search(:query => "Jäck")
    expect(results.records).to eq([@jack, @landscape])
  end

  it "should search within the comment" do
    @people = FactoryGirl.create :people
    @jack = FactoryGirl.create :jack, :comment => "chainsaw"
    described_class.index_all :full => true

    results = @elastic.search(:query => "chain")
    expect(results.records).to eq([@jack])
  end

end

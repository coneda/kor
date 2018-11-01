require 'rails_helper'

RSpec.describe Kor::Elastic, elastic: true do

  before :each do
  #   @admins = FactoryGirl.create :admins
  #   @admin = FactoryGirl.create :admin, :groups => [@admins]
  #   @default = FactoryGirl.create :default
  #   Grant.create(:collection => @default, :credential => @admins, :policy => :view)

    @elastic = described_class.new(User.admin)

  #   @media = FactoryGirl.create :media
  #   @locations = FactoryGirl.create :locations
    # @united_kingdom = FactoryGirl.create :united_kingdom, :tag_list => ["coast", "english language", "beer"]
    # @united_states = FactoryGirl.create :united_states, :tag_list => ["coast", "english language"]
    
    described_class.index_all
  end

  it 'should be enabled by rspec metadata' do
    expect(described_class.enabled?).to be_truthy

    described_class.disable
    expect(described_class.enabled?).to be_falsey

    described_class.enable
    expect(described_class.enabled?).to be_truthy
  end

  it "should index an entity" do
    Kor::Elastic.disable do
      @landscape = FactoryGirl.create :landscape
    end

    expect {
      described_class.index(@landscape)
      described_class.refresh
    }.to change{Kor::Elastic.count}.by(1)
  end

  it "should search with a full token" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'

    results = @elastic.search(term: "mona")
    expect(results.records).to eq([mona_lisa])

    results = @elastic.search(term: "\"mona lisa\"")
    expect(results.records).to eq([mona_lisa])
  end

  it "should search with partial terms" do
    leonardo = Entity.find_by! name: 'Leonardo'

    results = @elastic.search(term: "ardo")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "leon")
    expect(results.records).to eq([leonardo])
  end

  context 'with united counries' do
    before :each do
      @united_kingdom = FactoryGirl.create :united_kingdom, :tag_list => ["coast", "english language", "beer"]
      @united_states = FactoryGirl.create :united_states, :tag_list => ["coast", "english language"]

      described_class.index_all
    end

    it "should search with 1 tag" do
      results = @elastic.search(tags: ["coast"])
      expect(results.records.size).to eq(2)
    end

    it "should search with 2 tags" do
      results = @elastic.search(tags: ["coast", "beer"])
      expect(results.records).to eq([@united_kingdom])
    end

    it "should search with 2 tags with 2 words and two hits" do
      results = @elastic.search(tags: ["coast", "english language"])
      expect(results.records.size).to eq(2)
    end

    it "should search with 2 tags with 2 words and one hit otherwayround" do
      results = @elastic.search(tags: ["beer", "english language"])
      expect(results.records).to eq([@united_kingdom])
    end
  end

  it "should search within synonyms" do
    people = Kind.find_by! name: 'person'
    works = Kind.find_by! name: 'work'
    # @people = FactoryGirl.create :people
    # @works = FactoryGirl.create :works
    landscape = FactoryGirl.create :landscape, synonyms: ["Tree on plane", "Nice Tree"]
    jack = FactoryGirl.create :jack, synonyms: ["The Oak", "Tree on plane"]
    
    described_class.index_all

    # This is very nasty, however, there is no better workaround at the moment:
    # https://github.com/elasticsearch/elasticsearch/issues/1063
    # sleep 2

    # puts @elastic.search(term: "\"tree on plane\"").inspect

    results = @elastic.search(term: "\"tree on plane\"")
    expect(results.records.size).to eq(2)

    results = @elastic.search(term: "\"tree on plane\"", kind_id: people.id)
    expect(results.records).to eq([jack])

    results = @elastic.search(term: "\"tree on plane\"", kind_id: works.id)
    expect(results.records).to eq([landscape])

    is_related_to = FactoryGirl.create :relation, from_kind: landscape.kind, to_kind: jack.kind
    Relationship.relate_and_save(landscape, "is related to", jack)
    described_class.index_all full: true

    results = @elastic.search(term: ["\"tree on plane\"", "Oak"])
    expect(results.records).to include(jack, landscape)

    results = @elastic.search(term: ["\"tree on plane\"", "Jack"])
    expect(results.records).to include(jack, landscape)

    results = @elastic.search(term: ["\"tree on plane\"", "Jack"], kind_id: people.id)
    expect(results.records).to eq([jack])
  end

  it "should paginate entities when there are more than 10 results" do
    11.times do |i|
      FactoryGirl.create :landscape, name: "Auferstehung #{i}"
    end
    described_class.index_all

    results = @elastic.search(term: "Auferst")
    expect(results.total).to eq(11)
    expect(results.records.size).to eq(10)
  end

  it "should filter by collection" do
    priv = Collection.find_by! name: 'private'
    last_supper = Entity.find_by! name: 'The Last Supper'

    results = @elastic.search(collection_id: priv.id)
    expect(results.total).to eq(1)
    expect(results.records.first).to eq(last_supper)
  end

  it "should filter by collection and kind" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    louvre = Entity.find_by! name: 'Louvre'

    results = @elastic.search(kind_id: mona_lisa.kind_id)
    expect(results.total).to eq(2)

    results = @elastic.search(kind_id: louvre.kind_id)
    expect(results.total).to eq(1)

    results = @elastic.search(kind_id: mona_lisa.kind_id, collection_id: mona_lisa.collection_id)
    expect(results.total).to eq(1)
  end

  it "should search in the comment with low relevance" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    leonardo = Entity.find_by! name: 'Leonardo'
    mona_lisa.update comment: 'Leo'
    leonardo.update comment: 'Mona'

    described_class.index_all

    results = @elastic.search(term: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = @elastic.search(term: 'leo')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should serch in the properties with low relevance" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    leonardo = Entity.find_by! name: 'Leonardo'
    mona_lisa.update properties: ['label' => 'check', 'value' => 'Leo']
    leonardo.update properties: ['label' => 'check', 'value' => 'Mona']

    described_class.index_all

    results = @elastic.search(term: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = @elastic.search(term: 'leo')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should search in the display name with low relevance" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    leonardo = Entity.find_by! name: 'Leonardo'
    mona_lisa.update distinct_name: 'leo'
    leonardo.update distinct_name: 'mona'

    described_class.index_all

    results = @elastic.search(term: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = @elastic.search(term: 'leo')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should search by uuid and id" do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    results = @elastic.search(term: mona_lisa.uuid)
    expect(results.records).to eq([mona_lisa])
  end

  it "should search for special characters and do folding" do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.update name: 'Leonardo Müller'
    described_class.index_all

    results = @elastic.search(term: "Müller")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "ülle")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "muller")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "Üller")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "Mûller")
    expect(results.records).to eq([leonardo])

    results = @elastic.search(term: "Uller")
    expect(results.records).to eq([leonardo])
  end

  it "should not index media" do
    expect {
      FactoryGirl.create :picture_c
      described_class.index_all
    }.not_to change{@elastic.search.total}
  end

  it "should search within related entities with special characters" do
    leonardo = Entity.find_by! name: 'Leonardo'
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    last_supper = Entity.find_by! name: 'The Last Supper'
    leonardo.update name: 'Leonardo Müller'
    described_class.index_all full: true

    results = @elastic.search(term: "Mûller")
    expect(results.records).to include(leonardo, last_supper, mona_lisa)
  end

  it "should not fail when no results are returned" do
    results = @elastic.search(term: "doesnotexist")
    expect(results.uuids).to be_empty
    expect(results.ids).to be_empty
    expect(results.records).to be_empty
  end

  it "should search within the subtype" do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.update subtype: 'inventor'
    described_class.index_all

    results = @elastic.search(term: "inventor")
    expect(results.records).to eq([leonardo])
  end

  it "should accept a per_page parameter" do
    people = Kind.find_by! name: 'person'
    11.times do |i|
      FactoryGirl.create :jack, name: "Jack #{i}"
    end
    described_class.index_all full: true

    results = @elastic.search(kind_id: 999)
    expect(results.records.size).to eq(0)

    results = @elastic.search(kind_id: people.id)
    expect(results.records.size).to eq(10)

    results = @elastic.search(kind_id: people.id, per_page: 20)
    expect(results.records.size).to eq(12)

    expect(described_class).to receive(:request).with(
      anything, anything, anything,
      hash_including("size" => 500)
    ).and_call_original
    results = @elastic.search(kind_id: people.id, per_page: 700)
  end

  it "should not fail on short query terms" do
    results = @elastic.search(term: "xx")
    expect(results.records.size).to eq(5)
  end

  it 'should allow searching within several kinds' do
    works = Kind.find_by! name: 'work'
    locations = Kind.find_by! name: 'location'

    results = @elastic.search(kind_id: [works.id, locations.id])
    expect(results.records.size).to eq(3)
  end

  it 'should get the server version' do
    version = described_class.server_version
    expect(version.to_s).to match(/^\d+\.\d+\.\d+$/)
  end

  it 'should not crash with just an asterisk for synonyms' do
    expect {
      @elastic.search(synonyms: '*')
    }.not_to raise_error
  end

end

require 'rails_helper'

RSpec.describe Kor::Elastic, elastic: true do
  it 'should be enabled by rspec metadata' do
    expect(described_class.available?).to be_truthy

    described_class.disable!
    expect(described_class.available?).to be_falsey

    described_class.enable!
    expect(described_class.available?).to be_truthy
  end

  it "should index an entity" do
    Kor::Elastic.disable!
    @landscape = FactoryGirl.create :landscape
    Kor::Elastic.enable!

    expect{
      described_class.index(@landscape)
      described_class.refresh
    }.to change{ Kor::Elastic.count }.by(1)
  end

  it "should search with a full token" do
    results = described_class.new(User.admin).search(terms: "mona")
    expect(results.total).to eq(5)

    results = described_class.new(User.admin).search(terms: "\"mona lisa\"")
    expect(results.total).to eq(5)
  end

  it "should search with partial terms" do
    results = described_class.new(User.admin).search(terms: "*ardo*")
    expect(results.records).to include(leonardo, last_supper, mona_lisa)

    results = described_class.new(User.admin).search(terms: "leon*")
    expect(results.records).to include(leonardo, last_supper, mona_lisa)
  end

  context 'with united countries' do
    before :each do
      @united_kingdom = FactoryGirl.create :united_kingdom, :tag_list => ["coast", "english language", "beer"]
      @united_states = FactoryGirl.create :united_states, :tag_list => ["coast", "english language"]

      described_class.index_all
    end

    it "should search with 1 tag" do
      results = described_class.new(User.admin).search(tags: ["coast"])
      expect(results.records.size).to eq(2)
    end

    it "should search with 2 tags" do
      results = described_class.new(User.admin).search(tags: ["coast", "beer"])
      expect(results.records).to eq([@united_kingdom])
    end

    it "should search with 2 tags with 2 words and two hits" do
      results = described_class.new(User.admin).search(tags: ["coast", "english language"])
      expect(results.records.size).to eq(2)
    end

    it "should search with 2 tags with 2 words and one hit otherwayround" do
      results = described_class.new(User.admin).search(tags: ["beer", "english language"])
      expect(results.records).to eq([@united_kingdom])
    end
  end

  it "should search within synonyms" do
    landscape = FactoryGirl.create :landscape, synonyms: ["Tree on plane", "Nice Tree"]
    jack = FactoryGirl.create :jack, synonyms: ["The Oak", "Tree on plane"]

    described_class.index_all

    results = described_class.new(User.admin).search(terms: "\"tree on plane\"")
    expect(results.records.size).to eq(2)

    results = described_class.new(User.admin).search(terms: "\"tree on plane\"", kind_id: people.id)
    expect(results.records).to eq([jack])

    results = described_class.new(User.admin).search(terms: "\"tree on plane\"", kind_id: works.id)
    expect(results.records).to eq([landscape])

    FactoryGirl.create :relation, from_kind: landscape.kind, to_kind: jack.kind
    Relationship.relate_and_save(landscape, "is related to", jack)
    described_class.index_all full: true

    results = described_class.new(User.admin).search(terms: "\"tree on plane\" Oak")
    expect(results.records).to include(jack, landscape)

    results = described_class.new(User.admin).search(terms: "\"tree on plane\" Jack")
    expect(results.records).to include(jack, landscape)

    results = described_class.new(User.admin).search(terms: "\"tree on plane\" Jack", kind_id: people.id)
    expect(results.records).to eq([jack])
  end

  it "should paginate entities when there are more than 10 results" do
    11.times do |i|
      FactoryGirl.create :landscape, name: "Auferstehung #{i}"
    end
    described_class.index_all

    results = described_class.new(User.admin).search(terms: "Auferst*")
    expect(results.total).to eq(11)
    expect(results.records.size).to eq(10)
  end

  it "should filter by collection" do
    results = described_class.new(User.admin).search(collection_id: priv.id)
    expect(results.total).to eq(2)
    expect(results.records).to include(last_supper, picture_b)
  end

  it "should filter by collection and kind" do
    results = described_class.new(User.admin).search(kind_id: mona_lisa.kind_id)
    expect(results.total).to eq(2)

    results = described_class.new(User.admin).search(kind_id: louvre.kind_id)
    expect(results.total).to eq(1)

    results = described_class.new(User.admin).search(kind_id: mona_lisa.kind_id, collection_id: mona_lisa.collection_id)
    expect(results.total).to eq(1)
  end

  it "should search in the comment with low relevance" do
    mona_lisa.update comment: 'Leo'
    leonardo.update comment: 'Mona'

    described_class.index_all

    results = described_class.new(User.admin).search(terms: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = described_class.new(User.admin).search(terms: 'leo*')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should serch in the properties with low relevance" do
    mona_lisa.update properties: ['label' => 'check', 'value' => 'Leo']
    leonardo.update properties: ['label' => 'check', 'value' => 'Mona']

    described_class.index_all

    results = described_class.new(User.admin).search(terms: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = described_class.new(User.admin).search(terms: 'leo*')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should search in the display name with low relevance" do
    mona_lisa.update distinct_name: 'leo'
    leonardo.update distinct_name: 'mona'

    described_class.index_all

    results = described_class.new(User.admin).search(terms: 'mona')
    expect(results.records).to eq([mona_lisa, leonardo])

    results = described_class.new(User.admin).search(terms: 'leo*')
    expect(results.records).to eq([leonardo, mona_lisa])
  end

  it "should search by uuid and id" do
    results = described_class.new(User.admin).search(terms: mona_lisa.uuid)
    expect(results.records).to eq([mona_lisa])
  end

  it "should search for special characters and do folding" do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.update name: 'Leonardo Müller'
    described_class.index_all

    results = described_class.new(User.admin).search(terms: "Müller")
    expect(results.records).to eq([leonardo])

    results = described_class.new(User.admin).search(terms: "*ülle*")
    expect(results.records).to eq([leonardo])

    results = described_class.new(User.admin).search(terms: "muller")
    expect(results.records).to eq([leonardo])

    results = described_class.new(User.admin).search(terms: "*Üller")
    expect(results.records).to eq([leonardo])

    results = described_class.new(User.admin).search(terms: "Mûller")
    expect(results.records).to eq([leonardo])

    results = described_class.new(User.admin).search(terms: "*Uller")
    expect(results.records).to eq([leonardo])
  end

  it "should search within related entities with special characters" do
    leonardo = Entity.find_by! name: 'Leonardo'
    leonardo.update name: 'Leonardo Müller'
    described_class.index_all full: true

    results = described_class.new(User.admin).search(terms: "Mûller")
    expect(results.records).to include(leonardo, last_supper, mona_lisa)
  end

  it "should not fail when no results are returned" do
    results = described_class.new(User.admin).search(terms: "doesnotexist")
    expect(results.uuids).to be_empty
    expect(results.ids).to be_empty
    expect(results.records).to be_empty
  end

  it "should search within the subtype" do
    leonardo.update subtype: 'inventor'
    described_class.index_all

    results = described_class.new(User.admin).search(terms: "inventor")
    expect(results.records).to eq([leonardo])
  end

  it "should accept a per_page parameter" do
    11.times do |i|
      FactoryGirl.create :jack, name: "Jack #{i}"
    end
    described_class.index_all full: true

    results = described_class.new(User.admin).search(kind_id: 999)
    expect(results.records.size).to eq(0)

    results = described_class.new(User.admin).search(kind_id: people.id)
    expect(results.records.size).to eq(10)

    results = described_class.new(User.admin).search(kind_id: people.id, per_page: 20)
    expect(results.records.size).to eq(12)
  end

  it "should not fail on short query terms" do
    results = described_class.new(User.admin).search(terms: "*xx*")
    expect(results.records.size).to eq(0)
  end

  it 'should allow searching within several kinds' do
    results = described_class.new(User.admin).search(kind_id: [works.id, locations.id])
    expect(results.records.size).to eq(3)
  end

  it 'should get the server version' do
    version = described_class.server_version
    expect(version.to_s).to match(/^\d+\.\d+\.\d+$/)
  end

  it 'should not crash with just an asterisk for synonyms' do
    expect{
      described_class.new(User.admin).search(synonyms: '*')
    }.not_to raise_error
  end

  it 'should search within dataset fields' do
    pic = picture_a
    pic.dataset['license'] = 'CC BY 4.0'
    pic.save!

    described_class.index_all full: true

    results = described_class.new(User.admin).search(dataset: {license: 'CC BY'})
    expect(results.records.size).to eq(1)
  end

  it 'should search by name, allowing wildcards' do
    results = described_class.new(User.admin).search(name: 'mon')
    expect(results.records.size).to eq(0)

    results = described_class.new(User.admin).search(name: 'mona')
    expect(results.records.size).to eq(1)

    results = described_class.new(User.admin).search(name: 'mon*')
    expect(results.records.size).to eq(1)
  end

  it 'should handle elastic request fails gracefully' do
    response = described_class.raw_request 'GET', '/invalid'

    expect{
      described_class.require_ok(response)
    }.to raise_error(StandardError, /elastic request failed/)
  end
end

require "rails_helper"

RSpec.describe Kor::Import::WikiData, vcr: true do
  it "should retrieve GND, ULAN and Sandrart ids for Q762" do
    item = described_class.find('Q762')

    expect(item.property_value("P227")).to eq("118640445")
    expect(item.property_value("P245")).to eq("500010879")
    expect(item.property_value("P1422")).to eq("195")
  end

  it "should make SPARQL queries" do
    query = "
      SELECT ?id ?label
      WHERE {
        ?id wdt:P31 wd:Q19847637 .
        ?id rdfs:label ?label filter (lang(?label) = 'en') .
      }
    "

    response = described_class.sparql(query)
    expect(response.status).to be_between(200, 299)
  end

  it 'should retrieve identifier types' do
    results = described_class.identifier_types('en')
    expect(results).to include('id' => '227', 'label' => 'GND ID')
    expect(results).to include('id' => '245', "label" => 'ULAN ID')
    expect(results).to include('id' => '4119', "label" => 'NLS Geographic Names Place ID')
  end

  it "should retrieve all identifiers for Q762" do
    item = described_class.find('Q762')
    expect(item.identifiers.size).to eq(210)
    expect(item.identifiers).to include("id" => "866", "label" => "Perlentaucher ID", "value" => "leonardo-da-vinci")
    expect(item.identifiers).to include("id"=>"214", "label"=>"VIAF ID", "value"=>"24604287")
    expect(item.identifiers).to include("id" => "245", "label" => "ULAN ID", "value" => "500010879")
  end

  it "should retrieve all identifiers P31:Q19847637" do
    results = described_class.identifier_types('en')
    expect(results.size).to eq(5622)
    expect(results).to include("id" => "1992", "label" => "Plazi ID")
    expect(results).to include("id" => "1461", "label" => "Patientplus ID")
  end

  it 'should find all properties linking other wikidata items' do
    item = described_class.find('Q762')

    expect(item.properties).to include(
      'id' => 'P20', 'label' => 'place of death', 'values' => ['Q1122731']
    )
    expect(item.properties).to include(
      'id' => 'P735', 'label' => 'given name', 'values' => ['Q18220847']
    )
    expect(item.properties).to include(
      "id"=>"P19", "label"=>"place of birth", "values"=>["Q154184"]
    )
  end

  context 'import' do
    it 'should import an item' do
      item = described_class.find('Q762')
      item.import(User.admin, default, people)

      e = Entity.find_by!(name: 'Leonardo da Vinci')
      expect(e.dataset['wikidata_id']).to eq('Q762')
      expect(e.kind_name).to eq('person')
      expect(e.collection.name).to eq('Default')
    end

    it 'should import the associations between known items' do
      # we delete some entities created by the test setup
      leonardo.destroy
      mona_lisa.destroy
      last_supper.destroy
      expect(Relation.count).to be(6)
      expect(Relationship.count).to be(1)

      # leonardo
      described_class.find('Q762').import(User.admin, default, people)
      expect(Relationship.count).to be(1)

      # mona lisa
      described_class.find('Q12418').import(User.admin, default, works)
      expect(Relation.count).to be(7)
      expect(Relationship.count).to be(2)

      # the last supper
      described_class.find('Q128910').import(User.admin, default, works)
      expect(Relation.count).to be(7)
      expect(Relationship.count).to be(3)

      # he's imported as 'Leonardo da Vinci' from wikidata
      leonardo = Entity.find_by!(name: 'Leonardo da Vinci')
      rel = Relation.find_by!(name: 'creator')

      expect(Relation.count).to eq(7)
      expect(Relationship.count).to eq(3)
      expect(rel.relationships.first.from_id).to eq(mona_lisa.id)
      expect(rel.relationships.first.to_id).to eq(leonardo.id)
      expect(rel.relationships.last.from_id).to eq(last_supper.id)
      expect(rel.relationships.last.to_id).to eq(leonardo.id)
      expect(rel.identifier).to eq('P170')
      expect(rel.reverse_identifier).to eq('iP170')
    end

    it 'should not create new associations if told not to' do
      leonardo.destroy
      mona_lisa.destroy
      last_supper.destroy
      expect(Relation.count).to be(6)
      expect(Relationship.count).to be(1)

      Kor.settings['create_missing_relations'] = false

      # leonardo
      described_class.find('Q762').import(User.admin, default, people)
      expect(Relationship.count).to be(1)

      # mona lisa
      described_class.find('Q12418').import(User.admin, default, works)
      expect(Relation.count).to be(6)
      expect(Relationship.count).to be(1)

      # the last supper
      described_class.find('Q128910').import(User.admin, default, works)
      expect(Relation.count).to be(6)
      expect(Relationship.count).to be(1)
    end

    it 'should not touch existing entities' do
      entities = Entity.all.to_a
      before = Time.now

      described_class.find('Q762').import(User.admin, default, people)
      entities.each do |entity|
        expect(entity.updated_at).to be < before
      end
    end
  end

  context 'update' do
    it 'should update an existing entity' do
      described_class.find('Q762').update(leonardo)
      expect(leonardo.name).to eq('Leonardo')

      described_class.find('Q762').update(leonardo, attributes: true)
      leonardo = Entity.find_by!(name: 'Leonardo da Vinci')
      expect(leonardo.comment).to eq('Italian Renaissance polymath')
      expect(leonardo.dataset['wikidata_id']).to eq('Q762')
    end
  end
end

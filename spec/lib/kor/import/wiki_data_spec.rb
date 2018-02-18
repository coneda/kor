require "rails_helper"

describe Kor::Import::WikiData, :vcr => true do

  it "should find a record by GND (P227 = 118640445)" do
    skip 'api endpoint not available anymore'
    result = subject.find_by_attribute("227", "118640445")
    expect(result["items"].first).to eq(762)
  end

  it "should find a record by ULAN (P245 = 500010879)" do
    skip 'api endpoint not available anymore'
    result = subject.find_by_attribute("245", "500010879")
    expect(result["items"].first).to eq(762)
  end

  it "should find a record by Sandrart id (P1422 = 195)" do
    skip 'api endpoint not available anymore'
    result = subject.find_by_attribute("1422", "195")
    expect(result["items"].first).to eq(762)
  end

  it "should retrieve GND, ULAN and Sandrart ids for Q762" do
    expect(subject.attribute_for("Q762", "P227")).to eq("118640445")
    expect(subject.attribute_for("Q762", "P245")).to eq("500010879")
    expect(subject.attribute_for("Q762", "P1422")).to eq("195")
  end

  it "should make SPARQL queries" do
    query = "
      PREFIX wd: <http://www.wikidata.org/entity/> 
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT ?id ?label
      WHERE {
        ?id wdt:P31 wd:Q19847637 . 
        ?id rdfs:label ?label filter (lang(?label) = 'en') .
      }
    "

    response = subject.sparql(query)
    expect(response.status).to be_between(200, 299)
  end

  it 'should retrieve identifier types' do
    results = subject.identifier_types
    expect(results).to include('id'=>'227', 'label'=>'GND ID')
    expect(results).to include('id'=>'245', "label"=>'ULAN ID')
    expect(results).to include('id'=>'4119', "label"=>'NLS Geographic Names Place ID')
  end

  it "should retrieve all identifiers for Q762" do
    # skip "there are vcr issues with using ruby 2.1.5 and/or ruby 2.2.5"

    results = subject.identifiers_for("Q762")
    expect(results.size).to eq(84)
    expect(results).to include("id"=>"866", "label"=>"Perlentaucher ID", "value"=>"leonardo-da-vinci")
    expect(results).to include("id"=>"3219", "label"=>"Encyclopædia Universalis Online ID", "value"=>"leonard-de-vinci")
    expect(results).to include("id"=>"245", "label"=>"ULAN ID", "value"=>"500010879")
  end

  it "should retrieve all identifiers P31:Q19847637" do
    results = subject.identifier_types
    expect(results.size).to eq(1498)
    expect(results).to include("id" => "1992", "label" => "Plazi ID")
    expect(results).to include("id" => "1461", "label" => "Patientplus ID")
  end

  it 'should find all properties linking other wikidata items' do
    results = subject.internal_properties_for('Q762')
    
    expect(results).to include(
      'id' => 'P20', 'label' => 'place of death', 'values' => ['Q1122731']
    )
    expect(results).to include(
      'id' => 'P735', 'label' => 'given name', 'values' => ['Q18220847']
    )
    expect(results).to include(
      'id' => 'P972', 'label' => 'catalog', 'values' => ['Q5460604']
    )
  end

  context 'import' do

    before :each do
      @default = FactoryGirl.create :default
      @admins = FactoryGirl.create :admins
      @admin = FactoryGirl.create :admin, groups: [@admins]
      Kor::Auth.grant @default, :create, to: @admins
      @people = FactoryGirl.create :people, fields: [Field.new(name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true)]
      @works = FactoryGirl.create :works, fields: [Field.new(name: 'wikidata_id', show_label: 'Wikidata ID', is_identifier: true)]
    end


    it 'should simulate the import of an item' do
      results = subject.preflight(User.admin, 'default', 'Q762', 'person')
      expect(results['success']).to eq(true)
      expect(results['entity']['name']).to eq('Leonardo da Vinci')
      expect(results['entity']['kind_id']).to eq(@people.id)
      expect(results['entity']['dataset']['wikidata_id']).to eq('Q762')

      expect(Entity.count).to eq(0)
      expect(Relation.count).to eq(0)
      expect(Relationship.count).to eq(0)
    end

    it 'should import an item' do
      results = subject.import(User.admin, 'default', 'Q762', 'person')

      expect(results['success']).to eq(true)
      expect(results['message']).to eq('item has been imported')

      e = Entity.find_by!(name: 'Leonardo da Vinci')
      expect(e.dataset['wikidata_id']).to eq('Q762')
      expect(e.kind_name).to eq('person')
      expect(e.collection.name).to eq('default')
      expect(e.id).to eq(results['entity']['id'])
      expect(e.uuid).to eq(results['entity']['uuid'])
    end

    it 'should import the associations between known items' do
      results = subject.import(User.admin, 'default', 'Q762', 'person')
      expect(results['success']).to eq(true)

      results = subject.import(User.admin, 'default', 'Q12418', 'Werk')
      expect(results['message']).to eq('item has been imported')

      results = subject.import(User.admin, 'default', 'Q128910', 'Werk')
      expect(results['message']).to eq('item has been imported')

      leonardo = Entity.find_by!(name: 'Leonardo da Vinci')
      mona_lisa = Entity.find_by!(name: 'Mona Lisa')
      last_supper = Entity.find_by!(name: 'The Last Supper')
      rel = Relation.find_by!(name: 'creator')

      expect(Relation.count).to eq(1)
      expect(Relationship.count).to eq(2)
      expect(rel.relationships.first.from_id).to eq(mona_lisa.id)
      expect(rel.relationships.first.to_id).to eq(leonardo.id)
      expect(rel.relationships.last.from_id).to eq(last_supper.id)
      expect(rel.relationships.last.to_id).to eq(leonardo.id)
    end

    it 'should not touch existing entities'
  end

end
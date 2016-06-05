require "rails_helper"

describe Kor::Import::WikiData, :vcr => true do
  it "should find a record by GND (P227 = 118640445)" do
    result = described_class.new.find_by_attribute("227", "118640445")
    expect(result["items"].first).to eq(762)
  end

  it "should find a record by ULAN (P245 = 500010879)" do
    result = described_class.new.find_by_attribute("245", "500010879")
    expect(result["items"].first).to eq(762)
  end

  it "should find a record by Sandrart id (P1422 = 195)" do
    result = described_class.new.find_by_attribute("1422", "195")
    expect(result["items"].first).to eq(762)
  end

  it "should retrieve GND, ULAN and Sandrart ids for Q762" do
    expect(described_class.new.attribute_for("762", "227")).to eq("118640445")
    expect(described_class.new.attribute_for("762", "245")).to eq("500010879")
    expect(described_class.new.attribute_for("762", "1422")).to eq("195")
  end

  it "should retrieve all identifiers for Q762" do
    skip "there are vcr issues with using ruby 2.1.5 and/or ruby 2.2.5"

    results = described_class.new.identifiers_for("762")
    expect(results.size).to eq(23)
    expect(results).to include("id"=>"866", "label"=>"Perlentaucher ID", "value"=>"leonardo-da-vinci")
    expect(results).to include("id"=>"245", "label"=>"ULAN ID", "value"=>"500010879")
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

    response = described_class.new.sparql(query)
    expect(response.status).to be_between(200, 299)
  end

  it "should find all identifiers (P31:Q19847637)" do
    skip "there are vcr issues with using ruby 2.1.5 and/or ruby 2.2.5"
    
    results = described_class.new.identifier_types
    expect(results.size).to eq(347)
    expect(results).to include("id" => "1992", "label" => "Plazi ID")
    expect(results).to include("id" => "1461", "label" => "Patientplus ID")
  end

end
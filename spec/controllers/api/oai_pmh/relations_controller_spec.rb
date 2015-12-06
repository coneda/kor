require 'rails_helper'

describe Api::OaiPmh::RelationsController, :type => :controller do

  render_views

  before :each do
    FactoryGirl.create :admin

    FactoryGirl.create :has_created
    FactoryGirl.create :is_equivalent_to
  end

  it "should respond to 'Identify'" do
    get :identify, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :identify, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListSets'" do
    get :list_sets, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :list_sets, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListMetadataFormats'" do
    get :list_metadata_formats, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :list_metadata_formats, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListIdentifiers'" do
    get :list_identifiers, :format => :xml

    identifiers = Nokogiri::XML(response.body).xpath("//xmlns:identifier")

    expect(identifiers.count).to eq(2)
  end

  it "should respond to 'ListRecords'" do
    get :list_records, :format => :xml

    metadatas = Nokogiri::XML(response.body).xpath("//xmlns:metadata")
    items = metadatas.map{|m| Nokogiri::XML(m.children.to_s)}

    expect(items.count).to eq(2)
  end


  it "should respond to 'GetRecord'" do
    has_created = Relation.where(:name => "has created").first

    get :get_record, :format => :xml, :identifier => has_created.uuid
    expect(response).to be_success
    doc = Nokogiri::XML(response.body)
    items = doc.xpath("//xmlns:record")
    ns = doc.collect_namespaces
    expect(items.count).to eq(1)
    expect(items.first.xpath("//kor:name", ns).text).to eq("has created")
    expect(items.first.xpath("//kor:reverse-name", ns).text).to eq("has been created by")
  end

end
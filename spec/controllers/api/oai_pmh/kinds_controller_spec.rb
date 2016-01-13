require 'rails_helper'

describe Api::OaiPmh::KindsController, :type => :controller do

  render_views

  before :each do
    FactoryGirl.create :admin

    FactoryGirl.create :mona_lisa
    FactoryGirl.create :der_schrei
    FactoryGirl.create :leonardo

    FactoryGirl.create :media
    FactoryGirl.create :image_a
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

    expect(identifiers.count).to eq(3)
  end

  it "should respond to 'ListRecords'" do
    get :list_records, :format => :xml

    metadatas = Nokogiri::XML(response.body).xpath("//xmlns:metadata")
    items = metadatas.map{|m| Nokogiri::XML(m.children.to_s)}

    expect(items.count).to eq(3)
  end


  it "should respond to 'GetRecord'" do
    people = Kind.where(:name => "Person").first

    get :get_record, :format => :xml, :identifier => people.uuid
    expect(response).to be_success

    doc = Nokogiri::XML(response.body)
    doc.collect_namespaces.each{|k, v| doc.root.add_namespace k, v}
    items = doc.xpath("//dc:description").map{|e| Nokogiri::XML(e.text)}

    expect(items.count).to eq(1)
    expect(items.first.xpath("//kor:name").text).to eq("Person")
  end

  it "should return XML that validates against the OAI-PMH schema" do
    people = Kind.where(:name => "Person").first

    # yes this suck, check out 
    # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
    # for a reason why it has to be done like this
    xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/spec/fixtures/oai_pmh.xsd")
    get :get_record, :format => :xml, :identifier => people.uuid
    doc = Nokogiri::XML(response.body)

    expect(xsd.validate(doc)).to be_empty
  end

end
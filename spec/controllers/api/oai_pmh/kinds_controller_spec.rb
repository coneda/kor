require 'rails_helper'

describe Api::OaiPmh::KindsController, :type => :controller do

  include XmlHelper

  render_views

  before :each do
    FactoryGirl.create :admin

    FactoryGirl.create :mona_lisa
    FactoryGirl.create :der_schrei
    FactoryGirl.create :leonardo

    FactoryGirl.create :media
    FactoryGirl.create :picture_a
  end

  it "should respond to 'Identify'" do
    get :identify, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :identify, :format => :xml
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

    identifiers = parse_xml(response.body).xpath("//xmlns:identifier")

    expect(identifiers.count).to eq(3)
  end

  it "should respond to 'ListRecords'" do
    get :list_records, format: :xml, metadataPrefix: 'kor'

    items = parse_xml(response.body).xpath("//kor:kind")

    expect(items.count).to eq(3)
  end


  it "should respond to 'GetRecord'" do
    people = Kind.where(:name => "Person").first

    get(:get_record,
      format: :xml,
      identifier: people.uuid,
      metadataPrefix: 'kor'
    )
    expect(response).to be_success

    items = parse_xml(response.body).xpath("//kor:kind")

    expect(items.count).to eq(1)
    expect(items.first.xpath("//kor:name").text).to eq("Person")
  end

  it "should return XML that validates against the OAI-PMH schema" do
    people = Kind.where(:name => "Person").first

    # yes this sucks, check out
    # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
    # for a reason why it has to be done like this
    xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/tmp/oai_pmh_validator.xsd")
    get :get_record, :format => :xml, :identifier => people.uuid
    doc = parse_xml(response.body)
    
    expect(xsd.validate(doc)).to be_empty
  end

  it "should disseminate oai_dc and kor metadata formats on GetRecord requests" do
    people = Kind.where(:name => "Person").first

    get(:get_record,
      :format => :xml,
      :identifier => people.uuid,
      :metadataPrefix => "oai_dc"
    )
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(1)

    get(:get_record,
      :format => :xml,
      :identifier => people.uuid,
      :metadataPrefix => "kor"
    )
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:kind").count).to eq(1)
  end

  it "should disseminate oai_dc and kor metadata formats on ListRecords requests" do
    get(:list_records, 
      :format => :xml, 
      :metadataPrefix => "oai_dc"
    )
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(3)

    get(:list_records, 
      :format => :xml, 
      :metadataPrefix => "kor"
    )
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:kind").count).to eq(3)
  end

  it "should return 'idDoesNotExist' if the identifier given does not exist" do
    get(:get_record, 
      format: :xml, 
      identifier: '1234', 
      metadataPrefix: 'kor'
    )

    verify_oaipmh_error 'idDoesNotExist'
  end

  it "should return 'noRecordsMatch' if the criteria do not yield any records" do
    Kind.destroy_all
    admin = User.admin

    get :list_identifiers, format: :xml
    verify_oaipmh_error 'noRecordsMatch'

    get(:list_records,
      format: :xml, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    )
    verify_oaipmh_error 'noRecordsMatch'
  end

end
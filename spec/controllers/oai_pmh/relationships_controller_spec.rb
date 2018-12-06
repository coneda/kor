require 'rails_helper'

RSpec.describe OaiPmh::RelationshipsController, type: :request do
  include XmlHelper

  it "should respond to 'Identify'" do
    get '/oai-pmh/relationships.xml', verb: 'Identify'
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error

    post '/oai-pmh/relationships.xml', verb: 'Identify'
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListMetadataFormats'" do
    get '/oai-pmh/relationships.xml', verb: 'ListMetadataFormats'
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListIdentifiers'" do
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'ListIdentifiers',
      api_key: admin.api_key
    }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListRecords'" do
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'GetRecord'" do
    admin = User.admin
    relationship = Relationship.last

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: relationship.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should only include data the user is authorized for" do
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }
    verify_oaipmh_error 'noRecordsMatch'

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      metadataPrefix: 'kor',
      api_key: admin.api_key
    }

    items = parse_xml(response.body).xpath("//kor:relationship")

    expect(items.count).to eq(7)
  end

  it "should respond with 403 if the user is not authorized" do
    relationship = Relationship.last

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: relationship.uuid, 
      metadataPrefix: 'kor'
    }

    expect(response.status).to be(403)
  end

  it "should return XML that validates against the OAI-PMH schema" do
    relationship = Relationship.last
    admin = User.admin

    # yes this sucks, check out 
    # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
    # for a reason why it has to be done like this
    xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/tmp/oai_pmh_validator.xsd")
    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: relationship.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)

    expect(xsd.validate(doc)).to be_empty
  end

  it "should disseminate oai_dc and kor metadata formats on GetRecord requests" do
    relationship = Relationship.last
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: relationship.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(1)

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: relationship.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:relationship").count).to eq(1)
  end

  it "should disseminate oai_dc and kor metadata formats on ListRecords requests" do
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      metadataPrefix: "oai_dc",
      api_key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(7)

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: "kor"
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:relationship").count).to eq(7)
  end

  it "should return 'idDoesNotExist' if the identifier given does not exist" do
    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: '1234', 
      metadataPrefix: 'kor'
    }

    verify_oaipmh_error 'idDoesNotExist'
  end

  it "should return 'noRecordsMatch' if the criteria do not yield any records" do
    Relationship.all.each { |r| r.really_destroy! }
    admin = User.admin

    get '/oai-pmh/relationships.xml', {
      verb: 'ListIdentifiers',
    }
    verify_oaipmh_error 'noRecordsMatch'

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    verify_oaipmh_error 'noRecordsMatch'
  end

  it 'should include deleted records' do
    admin = User.admin
    rel = Relationship.last
    rel.destroy

    get '/oai-pmh/relationships.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(6)
    expect(doc.xpath("//xmlns:metadata").count).to eq(6)

    get '/oai-pmh/relationships.xml', {
      verb: 'ListIdentifiers',
      api_key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(6)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: rel.uuid, 
      metadataPrefix: 'kor',
      api_key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)
  end

  it 'should include properties' do
    admin = User.admin
    rel = Relationship.last

    rel.update properties: ['by wikidata', 'A559']

    get '/oai-pmh/relationships.xml', {
      verb: 'GetRecord',
      identifier: rel.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }

    doc = parse_xml(response.body)
    properties = doc.xpath("//kor:relationship/kor:properties/kor:property")
    expect(properties.count).to eq(2)
    expect(properties.first.text).to eq('by wikidata')
    expect(properties.last.text).to eq('A559')
  end
end
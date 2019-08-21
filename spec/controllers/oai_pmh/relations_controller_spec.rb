require 'rails_helper'

RSpec.describe OaiPmh::RelationsController, type: :request do
  include XmlHelper

  it "should respond to 'Identify'" do
    get '/oai-pmh/relations.xml', params: { verb: 'Identify' }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error

    post '/oai-pmh/relations.xml', params: { verb: 'Identify' }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListMetadataFormats'" do
    get '/oai-pmh/relations.xml', params: { verb: 'ListMetadataFormats' }
    expect(response).to be_success
    expect { Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListIdentifiers'" do
    get '/oai-pmh/relations.xml', params: { verb: 'ListIdentifiers' }

    identifiers = parse_xml(response.body).xpath("//xmlns:identifier")

    expect(identifiers.count).to eq(6)
  end

  it "should respond to 'ListRecords'" do
    get '/oai-pmh/relations.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }

    items = parse_xml(response.body).xpath("//kor:relation")

    expect(items.count).to eq(6)
  end

  it "should respond to 'GetRecord'" do
    has_created = Relation.where(:name => "has created").first

    get '/oai-pmh/relations.xml', params: {
      verb: 'GetRecord',
      identifier: has_created.uuid,
      metadataPrefix: 'kor'
    }
    expect(response).to be_success

    items = parse_xml(response.body).xpath("//kor:relation")

    expect(items.count).to eq(1)
    expect(items.first.xpath("//kor:name").text).to eq("has created")
    expect(items.first.xpath("//kor:reverse-name").text).to eq("has been created by")
  end

  if ENV['KOR_BRITTLE'] == 'true'
    it "should return XML that validates against the OAI-PMH schema" do
      relation = Relation.where(:name => "has created").first

      # yes this suck, check out
      # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
      # for a reason why it has to be done like this
      xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/tmp/oai_pmh_validator.xsd")
      get '/oai-pmh/relations.xml', params: {
        verb: 'GetRecord',
        identifier: relation.uuid,
        metadataPrefix: 'kor'
      }
      doc = parse_xml(response.body)

      expect(xsd.validate(doc)).to be_empty
    end
  end

  it "should disseminate oai_dc and kor metadata formats on GetRecord requests" do
    has_created = Relation.where(:name => "has created").first

    get '/oai-pmh/relations.xml', params: {
      verb: 'GetRecord',
      identifier: has_created.uuid,
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(1)

    get '/oai-pmh/relations.xml', params: {
      verb: 'GetRecord',
      identifier: has_created.uuid,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:relation").count).to eq(1)
  end

  it "should disseminate oai_dc and kor metadata formats on ListRecords requests" do
    get '/oai-pmh/relations.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(6)

    get '/oai-pmh/relations.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:relation").count).to eq(6)
  end

  it "should return 'idDoesNotExist' if the identifier given does not exist" do
    get '/oai-pmh/relations.xml', params: {
      verb: 'GetRecord',
      identifier: '1234',
      metadataPrefix: 'kor'
    }

    verify_oaipmh_error 'idDoesNotExist'
  end

  it "should return 'noRecordsMatch' if the criteria do not yield any records" do
    Relation.all.each { |r| r.really_destroy! }

    get '/oai-pmh/relations.xml', params: { verb: 'ListIdentifiers' }
    verify_oaipmh_error 'noRecordsMatch'

    get '/oai-pmh/relations.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }
    verify_oaipmh_error 'noRecordsMatch'
  end

  it 'should include deleted records' do
    admin = User.admin
    has_created = Relation.find_by(name: 'has created')
    has_created.destroy

    get '/oai-pmh/relations.xml', params: {
      verb: 'ListRecords',
      key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(5)
    expect(doc.xpath("//xmlns:metadata").count).to eq(5)

    get '/oai-pmh/relations.xml', params: {
      verb: 'ListIdentifiers',
      key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(5)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)

    get '/oai-pmh/relations.xml', params: {
      verb: 'GetRecord',
      identifier: has_created.uuid,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)
  end
end

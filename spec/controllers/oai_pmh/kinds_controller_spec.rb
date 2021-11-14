require 'rails_helper'

RSpec.describe OaiPmh::KindsController, type: :request do
  include XmlHelper

  it "should respond to 'Identify'" do
    get '/oai-pmh/kinds.xml', params: {verb: 'Identify'}
    expect(response).to be_successful
    expect{ Hash.from_xml response.body }.not_to raise_error

    post '/oai-pmh/kinds.xml', params: {verb: 'Identify'}
    expect(response).to be_successful
    expect{ Hash.from_xml response.body }.not_to raise_error

    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:deletedRecord").first.text).to eq('persistent')
  end

  it "should respond to 'ListMetadataFormats'" do
    get '/oai-pmh/kinds.xml', params: {verb: 'ListMetadataFormats'}
    expect(response).to be_successful
    expect{ Hash.from_xml response.body }.not_to raise_error
  end

  it "should respond to 'ListIdentifiers'" do
    get '/oai-pmh/kinds.xml', params: {verb: 'ListIdentifiers'}

    identifiers = parse_xml(response.body).xpath("//xmlns:identifier")

    expect(identifiers.count).to eq(5)
  end

  it "should respond to 'ListRecords'" do
    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListRecords', metadataPrefix: 'kor'
    }

    items = parse_xml(response.body).xpath("//kor:kind")

    expect(items.count).to eq(5)
  end

  it "should respond to 'GetRecord'" do
    people = Kind.where(:name => "Person").first

    get '/oai-pmh/kinds.xml', params: {
      verb: 'GetRecord',
      identifier: people.uuid,
      metadataPrefix: 'kor'
    }
    expect(response).to be_successful

    items = parse_xml(response.body).xpath("//kor:kind")

    expect(items.count).to eq(1)
    expect(items.first.xpath('kor:name').text).to eq('person')
  end

  if ENV['KOR_BRITTLE'] == 'true'
    it "should return XML that validates against the OAI-PMH schema" do
      people = Kind.where(:name => "Person").first
      people.update_attributes fields: [
        Field.new(name: 'gnd', show_label: 'GND-ID')
      ]

      # yes this sucks, check out
      # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
      # for a reason why it has to be done like this
      xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/tmp/oai_pmh_validator.xsd")
      get '/oai-pmh/kinds.xml', params: {
        verb: 'GetRecord',
        identifier: people.uuid,
        metadataPrefix: 'kor'
      }
      doc = parse_xml(response.body)

      expect(xsd.validate(doc)).to be_empty
    end
  end

  it "should disseminate oai_dc and kor metadata formats on GetRecord requests" do
    people = Kind.where(:name => "Person").first

    get '/oai-pmh/kinds.xml', params: {
      verb: 'GetRecord',
      identifier: people.uuid,
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(1)

    get '/oai-pmh/kinds.xml', params: {
      verb: 'GetRecord',
      identifier: people.uuid,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:kind").count).to eq(1)
  end

  it "should disseminate oai_dc and kor metadata formats on ListRecords requests" do
    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(5)

    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:kind").count).to eq(5)
  end

  it "should return 'idDoesNotExist' if the identifier given does not exist" do
    get '/oai-pmh/kinds.xml', params: {
      verb: 'GetRecord',
      identifier: '1234',
      metadataPrefix: 'kor'
    }

    verify_oaipmh_error 'idDoesNotExist'
  end

  it "should return 'noRecordsMatch' if the criteria do not yield any records" do
    Kind.all.each{ |r| r.really_destroy! }
    admin = User.admin

    get '/oai-pmh/kinds.xml', params: {verb: 'ListIdentifiers'}
    verify_oaipmh_error 'noRecordsMatch'

    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListRecords',
      key: admin.api_key,
      metadataPrefix: 'kor'
    }
    verify_oaipmh_error 'noRecordsMatch'
  end

  it 'should include deleted records' do
    admin = User.admin
    people = Kind.find_by(name: 'person')
    people.destroy

    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListRecords',
      key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(4)
    expect(doc.xpath("//xmlns:metadata").count).to eq(4)

    get '/oai-pmh/kinds.xml', params: {
      verb: 'ListIdentifiers',
      key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(4)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)

    get '/oai-pmh/kinds.xml', params: {
      verb: 'GetRecord',
      identifier: people.uuid,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)
  end
end

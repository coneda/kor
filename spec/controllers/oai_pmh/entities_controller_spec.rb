require 'rails_helper'

RSpec.describe OaiPmh::EntitiesController, type: :request do
  include XmlHelper

  before :each do
    guests = Credential.create! name: 'guests', users: [User.guest]
    default = Collection.find_by! name: 'default'
    Grant.create credential: guests, collection: default, policy: 'view'
  end

  it "should respond to 'Identify'" do
    get '/oai-pmh/entities.xml', verb: 'Identify'
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post '/oai-pmh/entities.xml', verb: 'Identify'
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListMetadataFormats'" do
    get '/oai-pmh/entities.xml', verb: 'ListMetadataFormats'
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListIdentifiers'" do
    get '/oai-pmh/entities.xml', verb: 'ListIdentifiers'
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListRecords'" do
    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end


  it "should respond to 'GetRecord'" do
    mona_lisa = Entity.first

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: mona_lisa.uuid, 
      metadataPrefix: 'kor'
    }
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should only include data the user is authorized for" do
    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      metadataPrefix: 'kor'
    }

    items = parse_xml(response.body).xpath('//kor:entity')

    expect(items.size).to eq(5)
    expect(items.first.xpath("//kor:title")[0].text).to eq("Leonardo")

    admin = User.admin
    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }

    items = parse_xml(response.body).xpath("//kor:entity")

    expect(items.count).to eq(7)
  end

  it "should respond with 403 if the user is not authorized" do
    leonardo = Entity.last

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid, 
      metadataPrefix: 'kor'
    }    

    expect(response.status).to be(403)
  end

  it "should return XML that validates against the OAI-PMH schema" do
    leonardo = Entity.last
    admin = User.admin

    leonardo.update_attributes(
      datings: [FactoryGirl.build(:leonardo_lifespan)],
      properties: [{'label' => 'age', 'value' => 53}]
    )

    # yes this sucks, check out 
    # https://mail.gnome.org/archives/xml/2009-November/msg0002it "should return 'badVerb' if the verb is not recognized"2.html
    # for a reason why it has to be done like this
    xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/tmp/oai_pmh_validator.xsd")
    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)

    expect(xsd.validate(doc)).to be_empty
  end

  it "should disseminate oai_dc and kor metadata formats on GetRecord requests" do
    leonardo = Entity.last
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(1)

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid, 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:entity").count).to eq(1)
  end

  it "should disseminate oai_dc and kor metadata formats on ListRecords requests" do
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'oai_dc'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/oai_dc:dc").count).to eq(7)

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:metadata/kor:entity").count).to eq(7)
  end

  it "should return 'idDoesNotExist' if the identifier given does not exist" do
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: '1234', 
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }

    verify_oaipmh_error 'idDoesNotExist'
  end

  it "should return 'noRecordsMatch' if the criteria do not yield any records" do
    Entity.all.each{|r| r.really_destroy!}
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'ListIdentifiers',
    }
    verify_oaipmh_error 'noRecordsMatch'

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    verify_oaipmh_error 'noRecordsMatch'
  end


  # The following tests actually test Api::OaiPmh::BaseController behavior. Therefore
  # they have no respective counterparts for other OAI-PMH controllers.

  specify "oai-pmh routes" do
    path = '/oai-pmh/entities.xml?verb=ListRecords'
    expect(Rails.application.routes.recognize_path path).to eq(
      format: "xml",
      controller: "oai_pmh/entities",
      action: "list_records"
    )
  end

  it "should return 'noSetHierarchy' if a set is requested" do
    get '/oai-pmh/entities.xml', verb: 'ListSets'
    verify_oaipmh_error 'noSetHierarchy'
  end

  it "should return 'cannotDisseminateFormat' if no format was specified" do
    leonardo = Entity.last
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid, 
      api_key: admin.api_key
    }
    verify_oaipmh_error 'cannotDisseminateFormat'

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key
    }

    verify_oaipmh_error 'cannotDisseminateFormat'
  end

  it "should return 'cannotDisseminateFormat' if the requested format doesn't exist" do
    leonardo = Entity.last
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: leonardo.uuid,
      api_key: admin.api_key,
      metadataPrefix: 'does_not_exist'
    }

    verify_oaipmh_error 'cannotDisseminateFormat'
  end

  it "should return 'badResumptionToken' when the resumptionToken is invalid" do
    admin = User.admin

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor',
      resumptionToken: '12345'
    }

    verify_oaipmh_error 'badResumptionToken'
  end

  it "should generate a resumptionToken if there are more pages available" do
    ns = {
      'oai' => 'http://www.openarchives.org/OAI/2.0/',
      'kor' => 'https://coneda.net/XMLSchema/1.0/'
    }

    zero = Time.now
    Entity.update_all updated_at: (zero - 2.hours)
    55.times do |i|
      FactoryGirl.create :mona_lisa, name: "Mona Lisa #{i}", updated_at: (zero - i.minutes)
    end

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor',
      from: (zero - 53.minutes).strftime('%Y-%m-%d %H:%M:%S')
    }

    doc = parse_xml(response.body)
    expect(doc.xpath('//kor:entity', ns).count).to eq(50)

    token = doc.xpath('//oai:resumptionToken', ns).first.text
    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor',
      resumptionToken: token
    }

    doc = parse_xml(response.body)
    expect(doc.xpath('//kor:entity', ns).count).to eq(3)

    expect(doc.xpath('//oai:resumptionToken', ns).size).to eq(1)
    expect(doc.xpath('//oai:resumptionToken', ns).text).to eq('')
    expect(File.exists? "#{subject.send :base_dir}/#{token}.json").to be_truthy
  end

  it 'should include deleted records' do
    admin = User.admin
    mona_lisa = Entity.find_by(name: 'Mona Lisa')
    mona_lisa.destroy

    get '/oai-pmh/entities.xml', {
      verb: 'ListRecords',
      api_key: admin.api_key,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(6)
    expect(doc.xpath("//xmlns:metadata").count).to eq(6)

    get '/oai-pmh/entities.xml', {
      verb: 'ListIdentifiers',
      api_key: admin.api_key
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:header[not(@status)]").count).to eq(6)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)

    get '/oai-pmh/entities.xml', {
      verb: 'GetRecord',
      identifier: mona_lisa.uuid,
      metadataPrefix: 'kor'
    }
    doc = parse_xml(response.body)
    expect(doc.xpath("//xmlns:header[@status='deleted']").count).to eq(1)
    expect(doc.xpath("//xmlns:metadata").count).to eq(0)
  end

end
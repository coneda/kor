require 'rails_helper'

describe Api::OaiPmh::RelationshipsController, :type => :controller do

  render_views

  before :each do
    default = FactoryGirl.create :default
    priv = FactoryGirl.create :private
    admins = FactoryGirl.create :admins
    FactoryGirl.create :admin, :groups => [admins]
    guests = FactoryGirl.create :guests
    FactoryGirl.create :guest, :groups => [guests]
    Grant.create :credential => guests, :collection => default, :policy => 'view'

    Grant.create :credential => admins, :collection => default, :policy => 'view'
    Grant.create :credential => admins, :collection => priv, :policy => 'view'

    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo, :collection_id => priv.id

    FactoryGirl.create :has_created
    Relationship.relate_and_save mona_lisa, "has created", leonardo
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
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :list_identifiers, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should respond to 'ListRecords'" do
    get :list_records, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :list_records, :format => :xml
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end


  it "should respond to 'GetRecord'" do
    admin = User.admin
    relationship = Relationship.last

    get :get_record, :format => :xml, :identifier => relationship.uuid, :api_key => admin.api_key
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :get_record, :format => :xml, :identifier => relationship.uuid, :api_key => admin.api_key
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

  it "should only include data the user is authorized for" do
    get :list_records, :format => :xml

    metadatas = Nokogiri::XML(response.body).xpath("//xmlns:metadata")
    items = metadatas.map{|m| Nokogiri::XML(m.children.to_s)}

    expect(items.count).to eq(0)

    admin = User.admin
    get :list_records, :format => :xml, :api_key => admin.api_key

    metadatas = Nokogiri::XML(response.body).xpath("//xmlns:metadata")
    items = metadatas.map{|m| Nokogiri::XML(m.children.to_s)}

    expect(items.count).to eq(1)
  end

  it "should respond with 403 if the user is not authorized" do
    relationship = Relationship.last

    get :get_record, :format => :xml, :identifier => relationship.uuid
    expect(response.status).to be(403)
  end

  it "should return XML that validates against the OAI-PMH schema" do
    relationship = Relationship.last
    admin = User.admin

    # yes this suck, check out 
    # https://mail.gnome.org/archives/xml/2009-November/msg00022.html
    # for a reason why it has to be done like this
    xsd = Nokogiri::XML::Schema(File.read "#{Rails.root}/spec/fixtures/oai_pmh.xsd")
    get :get_record, :format => :xml, :identifier => relationship.uuid, :api_key => admin.api_key
    doc = Nokogiri::XML(response.body)

    expect(xsd.validate(doc)).to be_empty
  end

end
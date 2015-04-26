require 'rails_helper'

describe Api::OaiPmh::RelationshipsController, :type => :controller do

  render_views

  before :each do
    default = FactoryGirl.create :default
    FactoryGirl.create :admin
    guests = FactoryGirl.create :guests
    FactoryGirl.create :guest, :groups => [guests]
    Grant.create :credential => guests, :collection => default, :policy => 'view'

    mona_lisa = FactoryGirl.create :mona_lisa
    leonardo = FactoryGirl.create :leonardo
    FactoryGirl.create :has_created
    Relationship.relate_once_and_save(leonardo, "has created", mona_lisa)
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
    relationship = Relationship.last

    get :get_record, :format => :xml, :identifier => relationship.uuid
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error

    post :get_record, :format => :xml, :identifier => relationship.uuid
    expect(response).to be_success
    expect{Hash.from_xml response.body}.not_to raise_error
  end

end
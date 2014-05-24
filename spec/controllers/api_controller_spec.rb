# encoding: utf-8

require 'spec_helper'

require "xmlsimple"

describe ApiController do
  include DataHelper
  
  render_views
  
  before :each do
    test_data
    
    Kor.config.update(
      'app' => {
        'gallery' => {
          'primary_relations' => ['stellt dar'], 
          'secondary_relations' => ['wurde erschaffen von']
      }},
      'auth' => { 
        'api' => { 'users' => [
          { 'username' => 'admin', 'password' => 'einhand', 'sections' => 'all'}
        ]
      }}
    )
  
    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:einhand")
  end
  
  it "should return status 401 when wrong authentication data was given" do
    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("admin:wrong")
    get 'invoke', :api_section => 'kor', :api_action => 'entity'
    response.status.should == 401
  end

  it "should not route the request when no action was given" do
    get 'invoke', :api_section => 'kor'
    response.status.should == 400
  end
  
  it "should return status 400 when an unknown action was given" do
    get 'invoke', :api_section => 'kor', :api_action => 'does_not_exist'
    response.status.should == 400
  end
  
  it "should render an entity as xml" do
    entity = @artwork_kind.entities.build(:name => 'Mona Lisa',
      :dataset => {:material => 'Öl'},
      :datings => [EntityDating.new(:label => 'Datierung', :dating_string => '1988')],
      :properties => [{:label => 'Age', :value => '455 Years'}],
      :synonyms => ['La Giocconde']
    )
    Entity.should_receive(:find_all_by_uuid_keep_order).and_return([entity])
    get 'invoke', :api_section => 'kor', :api_action => 'entity'
    response.should be_success
  end
  
  it "should render an entity with relationships as xml and include the relation ids" do
    leonardo = @person_kind.entities.make(:name => 'Leonardo')
    relationship = Relationship.relate_once_and_save(leonardo, 'hat erschaffen', @mona_lisa)
    
    get 'invoke', :api_section => 'kor', :api_action => 'entity', 
      :identifiers => @mona_lisa.uuid, 
      :magnitude => 'full'
      
    response.should have_selector('relation') do
      have_selector('id', :text => relationship.relation_id.to_s)
    end
  end

end

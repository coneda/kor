# encoding: utf-8

require 'spec_helper'

describe EntitiesController do
  render_views
  
  include DataHelper
  
  before :each do
    fake_authentication :persist => true
  
    test_kinds
  end
  
  def create_location(name, attributes)
    expect {
      attributes[:name] = name
      attributes[:kind_id] = Kind.find_by_name('Ort').id
      attributes[:collection_id] = @main.id
      post :create, :entity => attributes
    }.to change(Entity, :count).by(1)
  end
  
  it "should destroy an entity" do
    test_entities
    
    post :destroy, :id => @mona_lisa.id
    expect(Entity.exists?(@mona_lisa.id)).to be_falsey
  end
  
  it "should display the saved dating descriptor when editing" do
    test_entities
    @mona_lisa.datings.first.update_attributes(:label => 'Gemalt um')
  
    get :edit, :id => @mona_lisa.id

    expect(response).to have_selector("input[name^='entity[existing_datings_attributes]'][value='Gemalt um']")
  end
  
  it "should handle synonym attributes" do
    create_location 'Nürnberg', :synonyms => ["Nouremberg", "Nurnberg"]
    
    expect(Entity.last.synonyms.count).to eql(2)
    expect(Entity.last.synonyms.first).to eql("Nouremberg")
  end
  
  it "should handle property attributes" do
    create_location 'Nürnberg', :properties => [
      {:label => 'Einwohnerzahl', :value => "625000"},
      {:label => 'Fläche', :value => "225000km²"}
    ]
    
    expect(Entity.last.properties.count).to eql(2)
    expect(Entity.last.properties.first['label']).to eql("Einwohnerzahl")
  end
  
  it "should handle dating attributes" do
    create_location 'Nürnberg', :new_datings_attributes => [
      { :label => 'Datierung', :dating_string => '1599' },
      { :label => 'Datierung',  :dating_string => '1843' }
    ]
    
    expect(Entity.last.datings.count).to eql(2)
    expect(Entity.last.datings.first.dating_string).to eql("1599")
  end
  
  it "should handle a user group id" do
    user_group = FactoryGirl.create :user_group
    create_location 'Nürnberg', :user_group_id => user_group.id
    
    expect(user_group.entities.first.name).to eql('Nürnberg')
  end


  # ---------------------------------------------------------- authorization ---

  def side_collection
    @side_collection ||= FactoryGirl.create :private
  end
  
  def side_entity(attributes = {})
    @side_entity ||= FactoryGirl.create :leonardo, :collection => side_collection
  end
  
  def set_side_collection_policies(policies = {})
    policies.each do |p, c|
      side_collection.grant p, :to => c
    end
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      @main.grant p, :to => c
    end
  end


  # edit
  it "should not allow editing without appropriate authorization" do
    set_side_collection_policies :view => [@admins]
    entity = side_entity
    
    get :edit, :id => entity.id
    expect(response).to redirect_to(denied_path)
    
    put :update, :id => entity.id, :entity => {:collection_id => side_collection.id}
    expect(response).to redirect_to(denied_path)
  end
  
  # create
  it "should not allow creating entities without appropriate authorization" do
    @main.grants.destroy_all
    
    get :new
    expect(response).not_to have_selector("select[name='new_entity[kind_id]']")
    expect(response).to redirect_to(denied_path)
  end
  
  it "should allow creating entities given appropriate authorization" do
    get :new, :kind_id => @person_kind.id
    
    expect(response).not_to redirect_to(denied_path)
    expect(response).to have_selector("input[name='entity[collection_id]'][value='#{@main.id}']")
  end
  
  
  # delete
  it "should not allow deleting entities without appropriate authorization" do
    set_side_collection_policies :view => [@admins]
    
    delete :destroy, :id => side_entity.id
    expect(response).to redirect_to(denied_path)
  end
  
  # move
  it "should not allow moving entities between collections without appropriate authorization" do
    set_side_collection_policies :edit => [@admins]
    set_main_collection_policies :create => []
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    expect(response).to redirect_to(denied_path)
    
    set_main_collection_policies :create => [@admins]
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    expect(response).to redirect_to(denied_path)
    
    set_side_collection_policies :delete => [@admins]
    set_main_collection_policies :create => []
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    expect(response).to redirect_to(denied_path)
  end
  
  it "should allow moving entities between collections given appropriate authorization" do
    set_side_collection_policies :edit => [@admins], :delete => [@admins]
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    expect(response).not_to redirect_to(denied_path)
  end
  
  
  # recent entities

  it "should not show the recent entities without edit rights" do
    set_main_collection_policies :edit => []
    
    get :recent
    expect(response).to redirect_to(denied_path)
  end
  
  it "should show the recent entities with edit rights" do
    set_side_collection_policies :edit => [@admins]
  
    side_entity
    
    get :recent
    expect(response).to have_selector("a[href='#{entity_path(side_entity)}']")
  end
  
  
  # invalid entities

  it "should not show the invalid entities without delete rights" do
    set_main_collection_policies :delete => []
    
    get :invalid
    expect(response).to redirect_to(denied_path)
  end
  
  it "should show the invalid entities with delete rights" do
    set_side_collection_policies :delete => [@admins]
  
    FactoryGirl.create(:invalids).add_entities side_entity

    get :invalid
    path = web_path(:anchor => entity_path(side_entity))
    expect(response).to have_selector("a[href='#{path}']")
  end
  
  
  # menu
  
  it "should not show links to recent and invalid entities without authorization" do
    set_main_collection_policies :edit => [], :delete => []
  
    get :new
    expect(response).not_to have_selector("a[href='#{recent_entities_path}']")
    expect(response).not_to have_selector("a[href='#[invalid_entities_path]']")
  end
  
  it "should not show links to recent and invalid entities without authorization" do
    get :new, :kind_id => Kind.medium_kind.id
    expect(response).to have_selector("a[href='#{recent_entities_path}']")
    expect(response).to have_selector("a[href='#{invalid_entities_path}']")
  end

  it "should not create an entity of kind medium without a file" do
    post :create, :entity => {
      :collection_id => Collection.first.id,
      :name => "Some name",
      :kind_id => Kind.medium_kind.id
    }

    expect(response).not_to be_success

    post :create, :entity => {
      :collection_id => Collection.first.id,
      :name => "Some name",
      :kind_id => Kind.medium_kind.id,
      :medium_attributes => {}
    }

    expect(response).not_to be_success
  end
  
end

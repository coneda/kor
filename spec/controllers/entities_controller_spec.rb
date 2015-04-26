# encoding: utf-8

require 'spec_helper'

describe EntitiesController do
  render_views
  
  include DataHelper
  include AuthHelper
  
  before :each do
    fake_authentication :persist => true
  
    test_kinds
  end
  
  def create_location(name, attributes)
    lambda {
      attributes[:name] = name
      attributes[:kind_id] = Kind.find_by_name('Ort').id
      attributes[:collection_id] = @main.id
      post :create, :entity => attributes
    }.should change(Entity, :count).by(1)
  end
  
  it "should destroy an entity" do
    test_entities
    
    post :destroy, :id => @mona_lisa.id
    Entity.exists?(@mona_lisa.id).should be_false
  end
  
  it "should display the saved dating descriptor when editing" do
    test_entities
    @mona_lisa.datings.first.update_attributes(:label => 'Gemalt um')
  
    get :edit, :id => @mona_lisa.id
    
    response.should have_selector("input[name^='entity[existing_datings_attributes]'][value='Gemalt um']")
  end
  
  it "should handle synonym attributes" do
    create_location 'Nürnberg', :synonyms => ["Nouremberg", "Nurnberg"]
    
    Entity.last.synonyms.count.should eql(2)
    Entity.last.synonyms.first.should eql("Nouremberg")
  end
  
  it "should handle property attributes" do
    create_location 'Nürnberg', :properties => [
      {:label => 'Einwohnerzahl', :value => "625000"},
      {:label => 'Fläche', :value => "225000km²"}
    ]
    
    Entity.last.properties.count.should eql(2)
    Entity.last.properties.first['label'].should eql("Einwohnerzahl")
  end
  
  it "should handle dating attributes" do
    create_location 'Nürnberg', :new_datings_attributes => [
      { :label => 'Datierung', :dating_string => '1599' },
      { :label => 'Datierung',  :dating_string => '1843' }
    ]
    
    Entity.last.datings.count.should eql(2)
    Entity.last.datings.first.dating_string.should eql("1599")
  end
  
  it "should handle a user group id" do
    user_group = UserGroup.make
    create_location 'Nürnberg', :user_group_id => user_group.id
    
    user_group.entities.first.name.should eql('Nürnberg')
  end


  # ---------------------------------------------------------- authorization ---

  def side_collection
    @side_collection ||= Collection.make(:name => 'Side Collection')
  end
  
  def side_entity(attributes = {})
    @side_entity ||= @person_kind.entities.make attributes.reverse_merge(
      :collection => side_collection, 
      :name => 'Leonardo da Vinci'
    )
  end
  
  def main_entity(attributes = {})
    @main_entity ||= @artwork_kind.entities.make attributes.reverse_merge(
      :collection => @main, 
      :name => 'Mona Lisa'
    )
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


  # view
  it "should not show unauthorized entities" do
    entity = side_entity
    
    get :show, :id => entity.id
    response.should redirect_to(denied_path)
  end
  
  it "should show authorized entities" do
    set_side_collection_policies :view => [@admins]
    
    entity = side_entity
    
    get :show, :id => entity.id
    
    response.should_not redirect_to(denied_path)
  end
  
  
  # edit
  it "should not allow editing without appropriate authorization" do
    set_side_collection_policies :view => [@admins]
    entity = side_entity
    
    get :edit, :id => entity.id
    response.should redirect_to(denied_path)
    
    put :update, :id => entity.id, :entity => {:collection_id => side_collection.id}
    response.should redirect_to(denied_path)
  end
  
  # create
  it "should not allow creating entities without appropriate authorization" do
    @main.grants.destroy_all
    
    get :index
    response.should_not have_selector("select[name='new_entity[kind_id]']")
    
    get :new
    
    response.should redirect_to(denied_path)
  end
  
  it "should allow creating entities given appropriate authorization" do
    get :new, :kind_id => @person_kind.id
    
    response.should_not redirect_to(denied_path)
    response.should have_selector("input[name='entity[collection_id]'][value='#{@main.id}']")
  end
  
  
  # delete
  it "should not allow deleting entities without appropriate authorization" do
    set_side_collection_policies :view => [@admins]
  
    get :show, :id => side_entity.id
    response.should_not have_selector(".section_panel > .header > -commands img[alt='X']")
        
    delete :destroy, :id => side_entity.id
    response.should redirect_to(denied_path)
  end
  
  # move
  it "should not allow moving entities between collections without appropriate authorization" do
    set_side_collection_policies :edit => [@admins]
    set_main_collection_policies :create => []
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    response.should redirect_to(denied_path)
    
    set_main_collection_policies :create => [@admins]
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    response.should redirect_to(denied_path)
    
    set_side_collection_policies :delete => [@admins]
    set_main_collection_policies :create => []
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    response.should redirect_to(denied_path)
  end
  
  it "should allow moving entities between collections given appropriate authorization" do
    set_side_collection_policies :edit => [@admins], :delete => [@admins]
    
    put :update, :id => side_entity.id, :entity => {
      :collection_id => @main.id
    }
    response.should_not redirect_to(denied_path)
  end
  
  
  # relationships
  it "should not show relationships to unauthorized entities" do
    Relation.make(:name => 'hat erschaffen', :reverse_name => 'wurde erschaffen von')
    
    Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
    
    get :show, :id => main_entity.id
    response.should_not contain('Leonardo da Vinci')
  end
  
  it "should not show the edit nor delete buttons for unauthorized relationships" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []

    Relation.make(:name => 'hat erschaffen', :reverse_name => 'wurde erschaffen von')
    relationship = Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
    
    get :show, :id => main_entity.id
    response.should_not have_selector "a[href='#{edit_relationship_path(relationship)}']"
  end
  
  it "should not show media previews for unauthorized media entities" do
    medium = Entity.make(:medium, 
      :collection => side_collection,
      :medium => Medium.make_unsaved
    )
    artwork = main_entity
    person = Entity.make(:kind => @person_kind, :name => 'Leonardo da Vinci')
    
    Relation.make(:name => 'stellt dar', :reverse_name => 'wird dargestellt von')
    Relation.make(:name => 'hat erschaffen', :reverse_name => 'wurde erschaffen von')
    
    Relationship.relate_and_save(medium, 'stellt dar', artwork)
    Relationship.relate_and_save(artwork, 'hat erschaffen', person)
    
    get :show, :id => person.id
    response.should_not have_selector("a[href='#{entity_path(medium)}']")
  end
  
  # recent entities
  it "should not show the recent entities without edit rights" do
    set_main_collection_policies :edit => []
    
    get :recent
    response.should redirect_to(denied_path)
  end
  
  it "should show the recent entities with edit rights" do
    set_side_collection_policies :edit => [@admins]
  
    side_entity
    
    get :recent
    response.should have_selector("a[href='#{entity_path(side_entity)}']")
  end
  
  
  # invalid entities
  it "should not show the invalid entities without delete rights" do
    set_main_collection_policies :delete => []
    
    get :invalid
    response.should redirect_to(denied_path)
  end
  
  it "should show the invalid entities with delete rights" do
    set_side_collection_policies :delete => [@admins]
  
    SystemGroup.make(:name => "invalid").add_entities side_entity

    get :invalid
    response.should have_selector("a[href='#{entity_path(side_entity)}']")
  end
  
  
  # menu
  it "should not show links to recent and invalid entities without authorization" do
    set_main_collection_policies :edit => [], :delete => []
  
    get :index
    response.should_not have_selector("a[href='#{recent_entities_path}']")
    response.should_not have_selector("a[href='#[invalid_entities_path]']")
  end
  
  it "should not show links to recent and invalid entities without authorization" do
    get :index
    response.should have_selector("a[href='#{recent_entities_path}']")
    response.should have_selector("a[href='#{invalid_entities_path}']")
  end

  it "should not create an entity of kind medium without a file" do
    post :create, :entity => {
      :collection_id => Collection.first.id,
      :name => "Some name",
      :kind_id => Kind.medium_kind.id
    }

    response.should_not be_success

    post :create, :entity => {
      :collection_id => Collection.first.id,
      :name => "Some name",
      :kind_id => Kind.medium_kind.id,
      :medium_attributes => {}
    }

    response.should_not be_success
  end

  it "should deny uploading too big files" do
    file = fixture_file_upload("/image_c.jpg", 'image/jpeg')
    Kor.config["app.max_file_upload_size"] = 0.2

    post :create, :entity => {
      :kind_id => Kind.medium_kind.id,
      :collection_id => Collection.first.id,
      :medium_attributes => {
        :image => file
      }
    }

    expect(response.status).to be(406)
  end

  it "should allow uploading files of acceptable size" do
    file = fixture_file_upload("/image_c.jpg", 'image/jpeg')
    Kor.config["app.max_file_upload_size"] = 0.5

    post :create, :entity => {
      :kind_id => Kind.medium_kind.id,
      :collection_id => Collection.first.id,
      :medium_attributes => {
        :image => file
      }
    }

    expect(response.status).to be(302)
  end
  
end

require 'spec_helper'

describe RelationshipsController do
  render_views
  
  include DataHelper
  include AuthHelper

  before :each do
    test_data_for_auth
    test_kinds
    test_relations
    
    fake_authentication :user => @admin
  end
  
  it "should not switch relationships when rendering the edit form" do
    test_entities
    leonardo = Kind.find_by_name("Person").entities.make(:name => 'Leonardo da Vinci')
    relationship = Relationship.relate_and_save(Entity.find_by_name("Mona Lisa"), "wurde erschaffen von", leonardo)
    
    get :edit, :id => relationship.id
    
    response.should have_selector "select" do
     have_selector 'option[selected]', 'hat erschaffen'
    end
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
      side_collection.grant(p, :to => c)
    end
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      @main.grant p, :to => c
    end
  end
  
  
  # create
  it "should not allow to create relationships when not one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    session[:current_entity] = side_entity.id
        
    get :new, :relationship => {:from_id => main_entity.id}
    response.should redirect_to(denied_path)
    
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'hat erschaffen'
    }
    response.should redirect_to(denied_path)
  end
  
  it "should allow to create relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    session[:current_entity] = side_entity.id
        
    get :new, :relationship => {:from_id => main_entity.id}
    response.should_not redirect_to(denied_path)
    
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'hat erschaffen'
    }
    response.should_not redirect_to(denied_path)
  end
  
  
  # edit
  it "should not allow to edit relationships when not one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'hat erschaffen', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
        
    get :edit, :id => relationship.id
    response.should redirect_to(denied_path)
    
    get :edit, :id => relationship_reverse.id
    response.should redirect_to(denied_path)
    
    put :update, :id => relationship.id, :relationship => {
      :relation_name => 'stellt dar'
    }
    response.should redirect_to(denied_path)
    
    put :update, :id => relationship_reverse.id, :relationship => {
      :relation_name => 'wird dargestellt von'
    }
    response.should redirect_to(denied_path)
  end
  
  it "should allow to edit relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'hat erschaffen', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
        
    get :edit, :id => relationship.id
    response.should_not redirect_to(denied_path)
    
    get :edit, :id => relationship_reverse.id
    response.should_not redirect_to(denied_path)
    
    put :update, :id => relationship.id, :relationship => {
      :relation_name => 'stellt dar'
    }
    response.should_not redirect_to(denied_path)
    
    put :update, :id => relationship_reverse.id, :relationship => {
      :relation_name => 'wird dargestellt von'
    }
    response.should_not redirect_to(denied_path)
  end
  
  
  # delete
  it "should not allow to delete relationships when not one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'hat erschaffen', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
        
    delete :destroy, :id => relationship.id
    response.should redirect_to(denied_path)
    
    delete :destroy, :id => relationship_reverse.id
    response.should redirect_to(denied_path)
  end
  
  it "should allow to delete relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'hat erschaffen', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'hat erschaffen', main_entity)
        
    request.env["HTTP_REFERER"] = '/'
    delete :destroy, :id => relationship.id
    response.should_not redirect_to(denied_path)
    
    request.env["HTTP_REFERER"] = '/'
    delete :destroy, :id => relationship_reverse.id
    response.should_not redirect_to(denied_path)
  end
  
end

require 'rails_helper'

RSpec.describe RelationshipsController, :type => :controller do
  render_views
  
  include DataHelper

  before :each do
    test_data_for_auth
    test_kinds
    test_relations
    
    fake_authentication :user => @admin
  end
  
  it "should not switch relationships when rendering the edit form" do
    test_entities
    leonardo = FactoryGirl.create :leonardo
    relationship = Relationship.relate_and_save(Entity.find_by_name("Mona Lisa"), "has been created by", leonardo)
    
    get :edit, :id => relationship.id
    
    expect(response.body).to have_selector "select" do
      have_selector 'option[selected]', 'has created'
    end
  end
  
  # ---------------------------------------------------------- authorization ---
  
  def side_collection
    @side_collection ||= FactoryGirl.create :private
  end
  
  def side_entity(attributes = {})
    @side_entity ||= FactoryGirl.create :leonardo, :collection => side_collection
  end
  
  def main_entity(attributes = {})
    @main_entity ||= FactoryGirl.create :mona_lisa
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
    expect(response).to redirect_to(denied_path)
    
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'has created'
    }
    expect(response).to redirect_to(denied_path)
  end
  
  it "should allow to create relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    session[:current_entity] = side_entity.id
        
    get :new, :relationship => {:from_id => main_entity.id}
    expect(response).not_to redirect_to(denied_path)
    
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'has created'
    }
    expect(response).not_to redirect_to(denied_path)
  end
  
  
  # edit
  it "should not allow to edit relationships when not one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    get :edit, :id => relationship.id
    expect(response).to redirect_to(denied_path)
    
    get :edit, :id => relationship_reverse.id
    expect(response).to redirect_to(denied_path)
    
    put :update, :id => relationship.id, :relationship => {
      :relation_name => 'shows'
    }
    expect(response).to redirect_to(denied_path)
    
    put :update, :id => relationship_reverse.id, :relationship => {
      :relation_name => 'is shown by'
    }
    expect(response).to redirect_to(denied_path)
  end
  
  it "should allow to edit relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    get :edit, :id => relationship.id
    expect(response).not_to redirect_to(denied_path)
    
    get :edit, :id => relationship_reverse.id
    expect(response).not_to redirect_to(denied_path)
    
    put :update, :id => relationship.id, :relationship => {
      :relation_name => 'shows'
    }
    expect(response).not_to redirect_to(denied_path)
    
    put :update, :id => relationship_reverse.id, :relationship => {
      :relation_name => 'is shown by'
    }
    expect(response).not_to redirect_to(denied_path)
  end
  
  
  # delete
  it "should not allow to delete relationships when not one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    delete :destroy, :id => relationship.id
    expect(response).to redirect_to(denied_path)
    
    delete :destroy, :id => relationship_reverse.id
    expect(response).to redirect_to(denied_path)
  end
  
  it "should allow to delete relationships when one entity is editable and the other is viewable" do
    set_side_collection_policies :view => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    request.env["HTTP_REFERER"] = '/'
    delete :destroy, :id => relationship.id
    expect(response).not_to redirect_to(denied_path)
    
    request.env["HTTP_REFERER"] = '/'
    delete :destroy, :id => relationship_reverse.id
    expect(response).not_to redirect_to(denied_path)
  end
  
end

require 'rails_helper'

RSpec.describe RelationshipsController, :type => :controller do
  render_views
  
  include DataHelper

  before :each do
    request.headers['accept'] = 'application/json'
  end
  
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
      side_collection.revoke :all, from: c
      side_collection.grant(p, :to => c)
    end
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      @main.revoke :all, from: c
      @main.grant p, :to => c
    end
  end

  it "should not allow to create relationships when not one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    session[:current_entity] = side_entity.id
        
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'has created'
    }
    expect(response.status).to eq(403)
  end
  
  it "should allow to create relationships when one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

    set_side_collection_policies :view => [@admins]
  
    session[:current_entity] = side_entity.id
        
    post :create, :relationship => {
      :from_id => main_entity.id,
      :to_id => side_entity.id,
      :relation_name => 'has created'
    }
    expect(response.status).to eq(200)
  end
  
  it "should not allow to edit relationships when not one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    patch :update, :id => relationship.id, :relationship => {
      :relation_name => 'shows'
    }
    expect(response.status).to eq(403)
    
    patch :update, :id => relationship_reverse.id, :relationship => {
      :relation_name => 'is shown by'
    }
    expect(response.status).to eq(403)
  end
  
  it "should allow to delete relationships when one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

    set_side_collection_policies :view => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)

    delete :destroy, :id => relationship.id
    expect(response.status).to eq(200)
    
    delete :destroy, :id => relationship_reverse.id
    expect(response.status).to eq(200)
  end

  it "should not allow to delete relationships when not one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations

    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => []
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    delete :destroy, id: relationship.id, api_key: @admin.api_key
    expect(response.status).to eq(403)
    
    delete :destroy, :id => relationship_reverse.id
    expect(response.status).to eq(403)
  end

  it "should allow to edit relationships when one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations

    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => [@admins]
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    patch :update, :id => relationship.id, api_key: @admin.api_key, :relationship => {
      :relation_name => 'shows'
    }
    expect(response).to be_success
    
    patch :update, :id => relationship_reverse.id, api_key: @admin.api_key, :relationship => {
      :relation_name => 'is shown by'
    }
    expect(response).to be_success
  end

  it "should create a relationship by relation name" do
    default_setup
    @default.grant :edit, to: [@admins]
    @priv.grant :edit, to: [@admins]

    post(:create, 
      api_key: @admin.api_key,
      relationship: {
        from_id: @leonardo.id,
        relation_name: 'has created',
        to_id: @mona_lisa.id
      }
    )
    expect(response.status).to eq(200)

    expect(Relationship.count).to eq(1)
    expect(Relationship.first.from_id).to eq(@leonardo.id)
    expect(Relationship.first.relation_id).to eq(
      Relation.where(name: 'has created').first.id
    )
    expect(Relationship.first.to_id).to eq(@mona_lisa.id)
  end

  it "should create a relationship by reverse relation name" do
    default_setup
    @default.grant :edit, to: [@admins]
    @priv.grant :edit, to: [@admins]

    post(:create, 
      api_key: @admin.api_key,
      relationship: {
        from_id: @mona_lisa.id,
        relation_name: 'has been created by',
        to_id: @leonardo.id
      }
    )
    expect(response.status).to eq(200)

    expect(Relationship.count).to eq(1)
    expect(Relationship.first.from_id).to eq(@leonardo.id)
    expect(Relationship.first.relation_id).to eq(
      Relation.where(name: 'has created').first.id
    )
    expect(Relationship.first.to_id).to eq(@mona_lisa.id)
  end

  it "should update a relationship" do
    default_setup
    @default.grant :edit, to: [@admins]
    @priv.grant :edit, to: [@admins]
    relationship = Relationship.relate_and_save(
      @leonardo, 'has created', @mona_lisa
    )

    patch(:update,
      id: relationship.id,
      api_key: @admin.api_key,
      relationship: {
        from_id: @last_supper.id,
        relation_name: 'has been created by',
        to_id: @leonardo.id
      }
    )

    expect(Relationship.count).to eq(1)
    expect(Relationship.first.from_id).to eq(@leonardo.id)
    expect(Relationship.first.relation_id).to eq(
      Relation.where(name: 'has created').first.id
    )
    expect(Relationship.first.to_id).to eq(@last_supper.id)
  end

  it "should destroy a relationship" do
    default_setup
    @default.grant :edit, to: [@admins]
    @priv.grant :edit, to: [@admins]
    relationship = Relationship.relate_and_save(
      @leonardo, 'has created', @mona_lisa
    )

    delete :destroy, api_key: @admin.api_key, id: relationship.id
    expect(response.status).to eq(200)

    expect(Relationship.count).to eq(0)
  end
  
end

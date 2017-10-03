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
      Kor::Auth.grant side_collection, :all, from: c
      Kor::Auth.grant side_collection, p, :to => c
    end
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      Kor::Auth.revoke @main, :all, from: c
      Kor::Auth.grant @main, p, :to => c
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
      :from_id => side_entity.id,
      :to_id => main_entity.id,
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

    FactoryGirl.create :has_created, from_kind: main_entity.kind, to_kind: side_entity.kind
  
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

    FactoryGirl.create :has_created, from_kind: main_entity.kind, to_kind: side_entity.kind

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

    FactoryGirl.create :has_created, from_kind: main_entity.kind, to_kind: side_entity.kind
  
    relationship = Relationship.relate_and_save(main_entity, 'has created', side_entity)
    relationship_reverse = Relationship.relate_and_save(side_entity, 'has created', main_entity)
        
    delete :destroy, id: relationship.id, api_key: @admin.api_key
    expect(response.status).to eq(403)
    
    delete :destroy, :id => relationship_reverse.id
    expect(response.status).to eq(403)
  end

  # TODO: write this in a smarter way
  it "should allow to edit relationships when one entity is editable and the other is viewable" do
    test_data_for_auth
    test_kinds
    test_relations

    set_side_collection_policies :view => [@admins]
    set_main_collection_policies :edit => [@admins]

    FactoryGirl.create :has_created, from_kind: main_entity.kind, to_kind: side_entity.kind
    FactoryGirl.create :shows, from_kind: main_entity.kind, to_kind: side_entity.kind
    FactoryGirl.create :shows, from_kind: side_entity.kind, to_kind: main_entity.kind
  
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
    Kor::Auth.grant @default, :edit, to: [@admins]
    Kor::Auth.grant @priv, :edit, to: [@admins]

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
    Kor::Auth.grant @default, :edit, to: [@admins]
    Kor::Auth.grant @priv, :edit, to: [@admins]

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
    Kor::Auth.grant @default, :edit, to: [@admins]
    Kor::Auth.grant @priv, :edit, to: [@admins]
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
    Kor::Auth.grant @default, :edit, to: [@admins]
    Kor::Auth.grant @priv, :edit, to: [@admins]
    relationship = Relationship.relate_and_save(
      @leonardo, 'has created', @mona_lisa
    )

    expect {
      delete :destroy, api_key: @admin.api_key, id: relationship.id
    }.to change{DirectedRelationship.count}.by(-2)
    expect(response.status).to eq(200)

    expect(Relationship.count).to eq(0)
  end

  it 'should allow to set dating attributes' do
    admins = FactoryGirl.create :admins
    admin = FactoryGirl.create :admin, groups: [admins]
    default = FactoryGirl.create :default
    leonardo = FactoryGirl.create :leonardo
    mona_lisa = FactoryGirl.create :mona_lisa
    has_created = FactoryGirl.create :has_created, from_kind: leonardo.kind, to_kind: mona_lisa.kind

    Kor::Auth.grant default, [:view, :edit], to: admins

    current_user admin

    post :create, relationship: {
      relation_id: has_created.id,
      from_id: leonardo.id,
      to_id: mona_lisa.id,
      datings_attributes: [
        {label: 'Zeitspanne', dating_string: '15. Jahrhundert'},
        {label: 'zweite Phase', dating_string: '16. Jahrhundert'}
      ]
    }
    expect(Relationship.count).to eq(1)
    expect(Relationship.first.datings.count).to eq(2)

    patch :update, id: Relationship.first.id, relationship: {
      datings_attributes: [
        {id: Relationship.first.datings.first.id, _destroy: true}
      ]
    }
    expect(Relationship.count).to eq(1)
    expect(Relationship.first.datings.count).to eq(1)
  end
  
end

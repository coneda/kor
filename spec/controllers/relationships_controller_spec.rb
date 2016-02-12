require 'rails_helper'

RSpec.describe RelationshipsController, :type => :controller do
  render_views
  
  include DataHelper

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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
    test_data_for_auth
    test_kinds
    test_relations
    fake_authentication :user => @admin

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

  it "should list all relationships" do
    # test_data_for_auth
    # test_kinds
    # test_relations

    default = FactoryGirl.create :default
    side = FactoryGirl.create :collection, :name => "Side"

    FactoryGirl.create :has_created
    FactoryGirl.create :shows

    main_artist = FactoryGirl.create :jack, :collection => default
    side_artist = FactoryGirl.create :tom, :collection => side
    main_works = 10.times.map do |i|
      FactoryGirl.create :artwork, name: "artwork #{i}", collection: default
    end
    side_works = 2.times.map do |i|
      FactoryGirl.create :artwork, name: "side artwork #{i}", collection: side
    end
    (main_works + side_works[0..0]).each do |e|
      Relationship.relate_and_save(main_artist, 'has created', e)
    end
    Relationship.relate_and_save(main_artist, 'is shown by', side_works[1])
    Relationship.relate_and_save(side_artist, 'has created', side_works[1])
    students = FactoryGirl.create :students
    admins = FactoryGirl.create :admins
    admin = FactoryGirl.create :admin, :groups => [admins]
    jdoe = FactoryGirl.create :jdoe, :groups => [students]
    default.grant :view, :to => [admins, students]
    side.grant :view, :to => [admins]

    get :index, :format => 'json'
    expect(response.status).to eq(401)

    guest = FactoryGirl.create :guest

    get :index, :format => 'json'
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body).size).to eq(0)

    current_user = jdoe
    allow_any_instance_of(described_class).to receive(:current_user) do
      current_user
    end

    get :index, :format => 'json'
    expect(JSON.parse(response.body).size).to eq(10)

    get :index, :format => 'json', :page => 1
    expect(JSON.parse(response.body).size).to eq(10)

    get :index, :format => 'json', :page => 2
    expect(JSON.parse(response.body).size).to eq(2)

    get :index, :format => 'json', :per_page => 11
    expect(JSON.parse(response.body).size).to eq(11)

    get :index, :format => 'json', :per_page => 20
    expect(JSON.parse(response.body).size).to eq(12)

    current_user = admin

    get :index, :format => 'json', :per_page => 20
    expect(JSON.parse(response.body).size).to eq(13)

    get :index, :format => 'json', :per_page => 20, :to_ids => [
      main_works[2].id, side_works[1].id
    ]
    expect(JSON.parse(response.body).size).to eq(2)

    get :index, :format => 'json', :per_page => 20, :from_ids => [
      side_artist.id
    ]
    expect(JSON.parse(response.body).size).to eq(1)

    get :index, :format => 'json', :per_page => 20, :from_kind_ids => [
      Kind.find_by_name("Person").id
    ]
    expect(JSON.parse(response.body).size).to eq(12)

    get :index, :format => 'json', :per_page => 20, :to_kind_ids => [
      Kind.find_by_name("Person").id
    ]
    expect(JSON.parse(response.body).size).to eq(1)

    get :index, :format => 'json', :per_page => 20, :relation_names => [
      "shows"
    ]
    expect(JSON.parse(response.body).size).to eq(1)
  end
  
end

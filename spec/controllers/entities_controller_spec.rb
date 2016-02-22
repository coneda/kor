require 'rails_helper'

RSpec.describe EntitiesController, :type => :controller do
  render_views
  
  include DataHelper
  
  it "should destroy an entity" do
    default_setup
    current_user @admin
    
    post :destroy, :id => @mona_lisa.id
    expect(Entity.exists?(@mona_lisa.id)).to be_falsey
  end
  
  it "should handle synonym attributes" do
    default_setup
    current_user @admin

    post(:create, 
      entity: {
        kind_id: FactoryGirl.create(:locations).id,
        collection_id: @default.id,
        name: 'Nürnberg',
        synonyms: ["Nouremberg", "Nurnberg"]
      }
    )
    expect(response).to redirect_to("/blaze#/entities/#{Entity.last.id}")
    
    expect(Entity.last.synonyms.count).to eql(2)
    expect(Entity.last.synonyms.first).to eql("Nouremberg")
  end
  
  it "should handle property attributes" do
    default_setup
    current_user @admin

    post(:create, 
      entity: {
        kind_id: FactoryGirl.create(:locations).id,
        collection_id: @default.id,
        name: 'Nürnberg',
        properties: [
          {label: 'Einwohnerzahl', value: "625000"},
          {label: 'Fläche', value: "225000km²"}
        ]
      }
    )
    
    expect(Entity.last.properties.count).to eql(2)
    expect(Entity.last.properties.first['label']).to eql("Einwohnerzahl")
  end
  
  it "should handle dating attributes" do
    FactoryGirl.create :location, name: 'Nürnberg', datings_attributes: [
      {label: 'Datierung', dating_string: '1599'},
      {label: 'Datierung',  dating_string: '1843'}
    ]
    
    expect(Entity.last.datings.count).to eql(2)
    expect(Entity.last.datings.first.dating_string).to eql("1599")
  end
  
  it "should handle a user group id" do
    default_setup
    user_group = FactoryGirl.create :user_group
    current_user @admin

    post :create, {
      :entity => {
        :name => "Nürnberg",
        :kind_id => FactoryGirl.create(:locations).id,
        :collection_id => @default.id
      },
      :user_group_name => user_group.name
    }
    expect(response).to redirect_to("/blaze#/entities/#{Entity.last.id}")

    expect(user_group.reload.entities.first.name).to eql('Nürnberg')
  end

  it "should return meta data including primarily and secondarily related data" do
    default_setup pictures: true, relationships: true
    Kor.config.update('app' => {
      'gallery' => {
        'primary_relations' => ['shows'],
        'secondary_relations' => ['has been created by']
      }
    })
    current_user @admin

    get :metadata, id: Medium.first.entity.id
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('text/plain')
    expect(response.body).to match(/Mona Lisa/)
    expect(response.body).to match(/Leonardo/)
  end

  context "authorization" do

    before :each do
      default_setup
    end

    def set_side_collection_policies(policies = {})
      policies.each do |p, c|
        @priv.grant p, :to => c
      end
    end
    
    def set_main_collection_policies(policies = {})
      policies.each do |p, c|
        @default.grant p, :to => c
      end
    end

    it "should not allow editing without appropriate authorization" do
      current_user @admin
      @priv.revoke :edit, from: @admins
      
      get :edit, :id => @last_supper.id
      expect(response).to redirect_to(denied_path)
      
      patch :update, :id => @last_supper.id, :entity => {:collection_id => @priv.id}
      expect(response).to redirect_to(denied_path)
    end
    
    it "should not allow creating entities without appropriate authorization" do
      current_user @jdoe
      
      get :new, kind_id: @media.id

      expect(response.body).to redirect_to(denied_path)      
    end
    
    it "should allow creating entities given appropriate authorization" do
      current_user @admin
      @default.grant :create, to: @admins

      get :new, kind_id: @people.id
      expect(response.status).to eq(200)
    end
    
    it "should not allow deleting entities without appropriate authorization" do
      current_user @jdoe

      delete :destroy, id: @mona_lisa.id
      expect(response).to redirect_to(denied_path)
    end
    
    it "should not allow moving entities between collections without appropriate authorization" do
      current_user @admin
      @default.revoke [:edit, :create, :delete], from: @admins
      @priv.revoke [:edit, :create, :delete], from: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response).to redirect_to(denied_path)
      
      @default.grant :create, to: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response).to redirect_to(denied_path)
      
      @default.grant :delete, to: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response).to redirect_to(denied_path)
    end
    
    it "should allow moving entities between collections given appropriate authorization" do
      current_user @admin
      @default.grant :create, to: @admins
      @priv.grant :edit, to: @admins
      @priv.grant :delete, to: @admins
            
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/blaze#/entities/#{@last_supper.id}")
    end
    
    it "should not show the recent entities without edit rights" do
      current_user @jdoe
      
      get :recent
      expect(response).to redirect_to(denied_path)
    end
    
    it "should show the recent entities with edit rights" do
      current_user @admin

      get :recent
      expect(response.status).to eq(200)
    end
    
    it "should not show the invalid entities without delete rights" do
      current_user @jdoe
      
      get :invalid
      expect(response).to redirect_to(denied_path)
    end
    
    it "should show the invalid entities with delete rights" do
      current_user @admin
    
      get :invalid
      expect(response.status).to eq(200)
    end
    
    it "should not show links to recent and invalid entities without authorization" do
      current_user @jdoe
    
      get :new
      expect(response.body).not_to have_selector("a[href='#{recent_entities_path}']")
      expect(response.body).not_to have_selector("a[href='#[invalid_entities_path]']")
    end
    
    it "should show links to recent and invalid entities with authorization" do
      current_user @admin

      get :new, :kind_id => Kind.medium_kind.id
      expect(response.body).to have_selector("a[href='#{recent_entities_path}']")
      expect(response.body).to have_selector("a[href='#{invalid_entities_path}']")
    end

    it "should not create an entity of kind medium without a file" do
      current_user @admin

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

    it "should deny uploading too big files" do
      current_user @admin

      file = fixture_file_upload("#{Rails.root}/spec/fixtures/image_c.jpg", 'image/jpeg')
      Kor.config["app.max_file_upload_size"] = 0.2

      post :create, :entity => {
        :kind_id => Kind.medium_kind.id,
        :collection_id => Collection.first.id,
        :medium_attributes => {
          :image => file
        }
      }

      expect(response.status).to eq(406)
    end

    it "should allow uploading files of acceptable size" do
      current_user @admin

      file = fixture_file_upload("#{Rails.root}/spec/fixtures/image_c.jpg", 'image/jpeg')
      Kor.config["app.max_file_upload_size"] = 0.5

      post :create, :entity => {
        :kind_id => Kind.medium_kind.id,
        :collection_id => Collection.first.id,
        :medium_attributes => {
          :image => file
        }
      }

      new_entity = Entity.last
      expect(response).to redirect_to("/blaze#/entities/#{new_entity.id}")
    end

    it "should allow guest requests" do
      guests = FactoryGirl.create :guests
      guest = FactoryGirl.create :guest, :groups => [guests]
      Grant.create :collection => @default, :credential => guests, :policy => "view"

      get :show, :id => @mona_lisa, :format => 'json'
      expect(response).to be_success
    end

  end
  
end

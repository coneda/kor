require 'rails_helper'

RSpec.describe EntitiesController, type: :controller do
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
  
  it "should handle property attributes", elastic: true do
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
    FactoryGirl.create :media
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
        Kor::Auth.grant @priv, p, :to => c
      end
    end
    
    def set_main_collection_policies(policies = {})
      policies.each do |p, c|
        Kor::Auth.grant @default, p, :to => c
      end
    end

    it "should not allow editing without appropriate authorization" do
      current_user @admin
      Kor::Auth.revoke @priv, :edit, from: @admins
      
      get :edit, :id => @last_supper.id
      expect(response.status).to eq(403)
      
      patch :update, :id => @last_supper.id, :entity => {:collection_id => @priv.id}
      expect(response.status).to eq(403)
    end
    
    it "should not allow creating entities without appropriate authorization" do
      current_user @jdoe
      
      get :new, kind_id: @media.id

      expect(response.status).to eq(403)
    end
    
    it "should allow creating entities given appropriate authorization" do
      current_user @admin
      Kor::Auth.grant @default, :create, to: @admins

      get :new, kind_id: @people.id
      expect(response.status).to eq(200)
    end
    
    it "should not allow deleting entities without appropriate authorization" do
      current_user @jdoe

      delete :destroy, id: @mona_lisa.id
      expect(response.status).to eq(403)
    end
    
    it "should restrict moving entities between collections" do
      current_user @admin
      Kor::Auth.revoke @default, [:edit, :create, :delete], from: @admins
      Kor::Auth.revoke @priv, [:edit, :create, :delete], from: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response.status).to eq(403)

      Kor::Auth.grant @default, :create, to: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response.status).to eq(403)
      
      Kor::Auth.grant @default, :delete, to: @admins
      
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      expect(response.status).to eq(403)
    end
    
    it "should allow moving entities between collections given appropriate authorization" do
      current_user @admin
      Kor::Auth.grant @default, :create, to: @admins
      Kor::Auth.grant @priv, :edit, to: @admins
      Kor::Auth.grant @priv, :delete, to: @admins
            
      patch :update, :id => @last_supper.id, :entity => {
        :collection_id => @default.id
      }
      
      expect(response.status).to eq(302)
      expect(response).to redirect_to("/blaze#/entities/#{@last_supper.id}")
    end
    
    it "should not show the recent entities without edit rights" do
      current_user @jdoe
      
      get :recent
      expect(response.status).to eq(403)
    end
    
    it "should show the recent entities with edit rights" do
      current_user @admin

      get :recent
      expect(response.status).to eq(200)
    end
    
    it "should not show the invalid entities without delete rights" do
      current_user @jdoe
      
      get :invalid
      expect(response.status).to eq(403)
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

  context 'JSON API' do

    before :each do
      @media = FactoryGirl.create :media
      @default = FactoryGirl.create :default
      @admins = FactoryGirl.create :admins
      @admin = FactoryGirl.create :admin, groups: [@admins]
      Kor::Auth.grant @default, :all, :to => @admins
      @works = FactoryGirl.create(:works,
        generators: [FactoryGirl.create(:language_indicator)],
        fields: [Field.new(name: 'viaf_id', show_label: 'stack')]
      )
      @people = FactoryGirl.create :people
      @mona_lisa = FactoryGirl.create(:mona_lisa, 
        synonyms: ['La Gioconda'],
        datings: [FactoryGirl.build(:d1533)],
        properties: [{'label' => 'shoe size', 'value' => '42'}],
        creator: @admin,
        updater: @admin,
        tag_list: ['nice', 'expensive']
      )
      @leonardo = FactoryGirl.create(:leonardo)
      FactoryGirl.create :has_created, from_kind: @leonardo.kind, to_kind: @mona_lisa.kind
      Relationship.relate_and_save @leonardo, 'has created', @mona_lisa
      @user_group = FactoryGirl.create :user_group, name: 'my stuff', owner: @admin
      @authority_group = FactoryGirl.create :authority_group, name: 'important stuff'
      @user_group.add_entities @mona_lisa
      @authority_group.add_entities @mona_lisa

      request.headers['api-key'] = @admin.api_key
    end

    it 'should retrieve entities by id or uuid' do
      get :show, id: @leonardo.id.to_s, format: 'json'
      data = JSON.parse(response.body)
      expect(data['id']).to eq(@leonardo.id)

      get :show, id: @leonardo.uuid, format: 'json'
      data = JSON.parse(response.body)
      expect(data['id']).to eq(@leonardo.id)
    end

    it 'should include the datings on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['datings']).to be_nil

      get :show, id: @mona_lisa.id, include: ['datings'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['datings']).to be_a(Array)
      expect(data['datings'].size).to eq(1)
      expect(data['datings'].first['dating_string']).to eq('1533')
    end

    it 'should include the dataset on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['dataset']).to be_nil

      get :show, id: @mona_lisa.id, include: ['dataset'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['dataset']['gnd']).to eq('12345')
    end

    it 'should include the relations on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['relations']).to be_nil

      get :show, id: @mona_lisa.id, include: ['relations'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['relations']).to eq(
        'has been created by' => 1  
      )
    end

    it 'should include the media relations on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['media_relations']).to be_nil

      get :show, id: @mona_lisa.id, include: ['media_relations'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['media_relations']).to eq({})
    end

    it 'should include related entities on demand' do
      mona = FactoryGirl.create :person, name: 'Mona'
      der_schrei = FactoryGirl.create :der_schrei
      picture_a = FactoryGirl.create :picture_a
      picture_b = FactoryGirl.create :picture_b
      FactoryGirl.create :shows, from_kind: picture_a.kind, to_kind: @mona_lisa.kind
      FactoryGirl.create :depicts, from_kind: picture_b.kind, to_kind: @mona_lisa.kind
      Relationship.relate_and_save picture_a, 'shows', @mona_lisa
      Relationship.relate_and_save picture_b, 'depicts', @mona_lisa
      # Relationship.relate_and_save picture_a, 'shows', mona
      # Relationship.relate_and_save @mona_lisa, 'shows', 
      # Relationship.relate_and_save picture_b, 'shows', der_schrei

      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['related']).to be_nil

      get :show, id: @mona_lisa.id, include: ['related'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['related'].size).to eq(3)
      expect(data['related'][0]['relation_name']).to eq('has been created by')
      expect(data['related'][0]['to']['name']).to eq('Leonardo da Vinci')
      expect(data['related'][1]['relation_name']).to eq('is shown by')
      expect(data['related'][1]['to']['id']).to eq(picture_a.id)
      expect(data['related'][1]['to']['medium']['url']).to include(
        'icon', 'thumbnail', 'preview', 'screen', 'normal', 'original'
      )
      expect(data['related'][2]['relation_name']).to eq('is depicted by')
      expect(data['related'][2]['to']['id']).to eq(picture_b.id)

      get(:show,
        id: @mona_lisa.id,
        include: ['related'],
        format: 'json',
        related_kind_id: @people.id
      )
      data = JSON.parse(response.body)
      expect(data['related'].size).to eq(1)

      get(:show,
        id: @mona_lisa.id,
        include: ['related'],
        format: 'json',
        related_relation_name: 'is depicted by'
      )
      data = JSON.parse(response.body)
      expect(data['related'].size).to eq(1)

      get(:show,
        id: @mona_lisa.id,
        include: ['related'],
        format: 'json',
        related_relation_name: ['is depicted by', 'is shown by']
      )
      data = JSON.parse(response.body)
      expect(data['related'].size).to eq(2)
    end

    it 'should include synonyms on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['synonyms']).to be_nil

      get :show, id: @mona_lisa.id, include: ['synonyms'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['synonyms']).to eq(['La Gioconda'])
    end

    it 'should include properties on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['properties']).to be_nil

      get :show, id: @mona_lisa.id, include: ['properties'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['properties']).to eq([
        {'label' => 'shoe size', 'value' => '42'}
      ])
    end

    it 'should include kind on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['kind_id']).to eq(@mona_lisa.kind_id)
      expect(data['kind']).to be_nil

      get :show, id: @mona_lisa.id, include: ['kind'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['kind_id']).to eq(@mona_lisa.kind_id)
      expect(data['kind']['name']).to eq(@mona_lisa.kind.name)
    end

    it 'should include collection on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['collection_id']).to eq(@mona_lisa.collection_id)
      expect(data['collection']).to be_nil

      get :show, id: @mona_lisa.id, include: ['collection'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['collection_id']).to eq(@mona_lisa.collection_id)
      expect(data['collection']['name']).to eq(@mona_lisa.collection.name)
    end

    it 'should include user groups on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['user_groups']).to be_nil

      get :show, id: @mona_lisa.id, include: ['user_groups'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['user_groups'].first['name']).to eq('my stuff')
    end

    it 'should include groups on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['groups']).to be_nil

      get :show, id: @mona_lisa.id, include: ['groups'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['groups'].first['name']).to eq('important stuff')
    end

    it 'should include technical info on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['created_at']).to be_nil

      get :show, id: @mona_lisa.id, include: ['technical'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['created_at']).not_to be_nil
    end

    it 'should calculate the degree on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['degree']).to be_nil

      get :show, id: @mona_lisa.id, include: ['degree'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['degree']).to eq(1)
    end

    it 'should include the editing users on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['creator_id']).to eq(@mona_lisa.creator_id)
      expect(data['creator']).to be_nil
      expect(data['updater_id']).to eq(@mona_lisa.updater_id)
      expect(data['updater']).to be_nil

      get :show, id: @mona_lisa.id, include: ['users'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['creator_id']).to eq(@mona_lisa.creator_id)
      expect(data['creator']['name']).to eq('admin')
      expect(data['updater_id']).to eq(@mona_lisa.updater_id)
      expect(data['updater']['name']).to eq('admin')
    end

    it 'should include fields on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['fields']).to be_nil

      get :show, id: @mona_lisa.id, include: ['fields'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['fields'].first['name']).to eq('viaf_id')
    end

    
    it 'should include generators on demand' do
      get :show, id: @mona_lisa.id, format: 'json'
      data = JSON.parse(response.body)
      expect(data['generators']).to be_nil

      get :show, id: @mona_lisa.id, include: ['generators'], format: 'json'
      data = JSON.parse(response.body)
      expect(data['generators'].first['name']).to eq('language_indicator')
    end

    it 'should include all on demand' do
      get :show, id: @mona_lisa.id, include: ['all'], format: 'json'
      data = JSON.parse(response.body)

      expect(data['datings'].first['dating_string']).to eq('1533')
      expect(data['dataset']['gnd']).to eq('12345')
      expect(data['relations']).to eq(
        'has been created by' => 1  
      )
      expect(data['synonyms']).to eq(['La Gioconda'])
      expect(data['properties']).to eq([
        {'label' => 'shoe size', 'value' => '42'}
      ])
      expect(data['kind']['name']).to eq(@mona_lisa.kind.name)
      expect(data['collection']['name']).to eq(@mona_lisa.collection.name)
      expect(data['user_groups'].first['name']).to eq('my stuff')
      expect(data['groups'].first['name']).to eq('important stuff')
      expect(data['created_at']).not_to be_nil
      expect(data['degree']).to eq(1)
    end

    it 'should apply the customized view to the index action' do
      get :index, format: 'json', include: ['all']
      data = JSON.parse(response.body)
      expect(data['records'].size).to eq(2)
      expect(data['records'].first['groups']).to eq([])
    end

    it 'should filter by comma-separated ids' do
      @der_schrei = FactoryGirl.create :der_schrei

      get :index, format: 'json', ids: "#{@mona_lisa.id},#{@leonardo.id}"
      data = JSON.parse(response.body)
      expect(data['ids']).to eq([@leonardo.id, @mona_lisa.id])

      get :index, format: 'json', ids: [@mona_lisa.id, @leonardo.id]
      data = JSON.parse(response.body)
      expect(data['ids']).to eq([@leonardo.id, @mona_lisa.id])
    end

  end

  # copied from legacy tools controller:

  it "should merge two entities with datings" do
    Entity.destroy_all

    original = FactoryGirl.create :mona_lisa, datings: [
      EntityDating.new(label: 'Dating', dating_string: '1503')
    ]
    duplicate = FactoryGirl.create :mona_lisa, name: 'Mona Liza', datings: [
      EntityDating.new(label: 'Dating', dating_string: '1603')
    ]
    entity_ids = [original.id, duplicate.id]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id,
      }

    expect(Entity.count).to eq(1)
    expect(Entity.first.datings.count).to eq(2)    
  end
  
  it "should merge two entities with datasets" do
    @monalisa = FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

    entity_ids = [
      @monalisa.id,
      @mona_lisa.id
    ]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id,
        :dataset => {:material => 'oil on paper'}
      }
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{Entity.first.id}"))

    expect(Entity.first.name).to eql("Mona Lisa")
    expect(Entity.first.dataset['material']).to eql('oil on paper')
    expect(Entity.first.dataset).not_to be_nil
  end

  # TODO: does this test the right thing?  
  it "should merge two entities while not messing up the groups" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }    

    entity_ids = [
      Entity.find_by_name("Mona Lisa").id,
      Entity.find_by_name("Monalisa").id
    ]

    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => { 
        :name => 'Mona Lisa', 
        :kind_id => Kind.find_by_name('Werk').id
      }
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{Entity.first.id}"))

    expect(Entity.first.name).to eql("Mona Lisa")
  end
  
  it "should merge two images while not messing up the groups" do
    picture_a = FactoryGirl.create :picture_a
    picture_b = FactoryGirl.create :picture_b
    
    entity_ids = [picture_a.id, picture_b.id]
    
    group_1 = AuthorityGroup.create(:name => 'group 1')
    group_1.add_entities(picture_a)
    group_1.add_entities(picture_b)
       
    group_2 = AuthorityGroup.create(:name => 'group 2')
    group_2.add_entities(picture_b)
    
    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => entity_ids,
      :entity => {:id => picture_a.id}
    
    expect(Entity.all).not_to include(picture_b)
    
    expect(picture_a.authority_groups).to include(group_1)
    expect(picture_a.authority_groups).to include(group_2)
      
    expect(response).to redirect_to(web_path(:anchor => "/entities/#{picture_a.id}"))
  end
  
  it "should merge entities while not loosing comments" do
    FactoryGirl.create :mona_lisa, :name => 'Monalisa', :dataset => {
      :gnd => '123456',
      :google_maps => 'Deutsche Straße 12, Frankfurt'
    }

    Entity.find_by_name('Mona Lisa').update_attributes(:comment => 'comment 1')
    Entity.find_by_name('Monalisa').update_attributes(:comment => 'comment 2')
  
    post :clipboard_action, 
      :clipboard_action => 'merge', 
      :entity_ids => Entity.all.map{|e| e.id},
      :entity => { 
        :name => 'Mona Lisa', 
        :comment => 'comment 1',
        :kind_id => Kind.find_by_name('Werk').id
      }
      
    expect(Entity.find_by_name('Mona Lisa').comment).to eql("comment 1")
  end
  
end

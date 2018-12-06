require 'rails_helper'

RSpec.describe EntitiesController, type: :controller do
  render_views

  it 'should GET index' do
    get 'index'
    expect_collection_response count: 0

    expect(Kor::Search).to receive(:new).with(
      User.guest, 
      hash_including(
        isolated: false,
        sort: { column: 'random', direction: 'asc' }
      )
    ).and_call_original

    get 'index', {
      isolated: false,
      sort: 'random'
    }
    expect_collection_response count: 0
  end

  it 'should GET existence' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    get 'existence', ids: [mona_lisa.id]
    expect(json).to eq({ mona_lisa.id.to_s => false })
  end

  it 'should GET show' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    get 'show', id: mona_lisa.id
    expect(response).to be_forbidden

    students = Credential.find_by! name: 'students'
    students.users << User.guest

    get 'show', id: mona_lisa.id
    expect(response).to be_success
  end

  it 'should not GET metadata' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    get 'metadata', id: mona_lisa.id
    expect(response).to be_forbidden
  end

  it 'should GET relation_counts' # action still relevant?

  it 'should not POST create' do
    post 'create', entity: { name: 'Danube' }
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    patch 'update', id: mona_lisa.id, entity: { name: 'Mona Liza' }
    expect(response).to be_forbidden
  end

  it 'should not PATCH update_tags' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    patch 'update_tags', id: mona_lisa.id, entity: { tags: 'pretty,smile' }
    expect(response).to be_forbidden
  end

  it 'should not POST merge' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    last_supper = Entity.find_by! name: 'The Last Supper'
    post 'merge', entity_ids: [mona_lisa.id, last_supper.id], entity: { name: 'Mona Lisa' }
    expect(response).to be_forbidden
  end

  it 'should not POST mass_relate' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    last_supper = Entity.find_by! name: 'The Last Supper'
    paris = Entity.find_by! name: 'Paris'
    post 'mass_relate', {
      id: paris.id,
      entity_ids: [mona_lisa.id, last_supper.id],
      relation_name: 'is related to'
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    mona_lisa = Entity.find_by! name: 'Mona Lisa'
    delete 'destroy', id: mona_lisa.id
    expect(response).to be_forbidden
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should GET index' do
      get 'index'
      expect_collection_response count: 5

      get 'index', kind_id: Kind.medium_kind_id
      expect_collection_response count: 1
      expect(json['records'][0]['primary_entities']).to be_nil

      get 'index', include: 'gallery_data', kind_id: Kind.medium_kind_id
      expect_collection_response count: 1
      expect(json['records'][0]['primary_entities'].size).to eq(1)

      Kor.settings.update(
        'primary_relations' => [],
        'secondary_relations' => []
      )
      
      get 'index', include: 'gallery_data', kind_id: Kind.medium_kind_id
      expect_collection_response count: 1
      expect(json['records'][0]['primary_entities'].size).to eq(0)
    end

    it 'should GET existence' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      get 'existence', ids: [mona_lisa.id]
      expect(json).to eq({ mona_lisa.id.to_s => true })
    end

    it 'should GET show' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      get 'show', id: mona_lisa.id
      expect(response).to be_success
      expect(json['name']).to eq('Mona Lisa')
      expect(json['relations']).to be_nil

      get 'show', id: mona_lisa.id, include: 'relations,technical'
      expect(response).to be_success
      expect(json['relations']['has been created by']).to eq(1)
      expect(json['relations']['is located in']).to eq(1)
      expect(json['uuid']).to be_nil

      get 'show', id: mona_lisa.uuid, include: 'relations,technical'
      expect(response).to be_success
    end

    it 'should GET metadata' do
      picture = Kind.medium_kind.entities.first
      get 'metadata', id: picture.id
      expect(response).to be_success
      expect(response.body).to match(/medium/)
      expect(response.body).to match(/Mona Lisa/)
      expect(response.body).to match(/Leonardo/)
    end

    it 'should GET relation_counts' # action still relevant?

    it 'should not POST create' do
      post 'create', entity: { name: 'Danube' }
      expect(response).to be_forbidden
    end

    it 'should not PATCH update' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      patch 'update', id: mona_lisa.id, entity: { name: 'Mona Liza' }
      expect(response).to be_forbidden
    end

    it 'should not PATCH update_tags' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      patch 'update_tags', id: mona_lisa.id, entity: { tags: 'pretty,smile' }
      expect(response).to be_forbidden
    end

    it 'should not POST merge' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      last_supper = Entity.find_by! name: 'The Last Supper'
      post 'merge', entity_ids: [mona_lisa.id, last_supper.id], entity: { name: 'Mona Lisa' }
      expect(response).to be_forbidden
    end

    it 'should not POST mass_relate' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      last_supper = Entity.find_by! name: 'The Last Supper'
      paris = Entity.find_by! name: 'Paris'
      post 'mass_relate', {
        id: paris.id,
        entity_ids: [mona_lisa.id, last_supper.id],
        relation_name: 'is related to'
      }
      expect(response).to be_forbidden
    end

    it 'should not DELETE destroy' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      delete 'destroy', id: mona_lisa.id
      expect(response).to be_forbidden
    end
  end

  context "as jdoe with permission 'view meta'" do
    before :each do
      default = Collection.find_by! name: 'default'
      students = Credential.find_by! name: 'students'
      Kor::Auth.grant default, :view_meta, to: students
      jdoe = User.find_by!(name: 'jdoe')

      current_user jdoe
    end

    it 'should GET show' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      get 'show', id: mona_lisa.id
      expect(response).to be_success
      expect(json['name']).to eq('Mona Lisa')
      expect(json['relations']).to be_nil

      get 'show', id: mona_lisa.id, include: 'relations,technical'
      expect(response).to be_success
      expect(json['relations']['has been created by']).to eq(1)
      expect(json['relations']['is located in']).to eq(1)
      expect(json['uuid']).not_to be_nil
    end
  end

  context "as jdoe with permission 'tagging'" do
    before :each do
      default = Collection.find_by! name: 'default'
      students = Credential.find_by! name: 'students'
      Kor::Auth.grant default, :tagging, to: students
      jdoe = User.find_by!(name: 'jdoe')

      current_user jdoe
    end

    it 'should PATCH update_tags' do
      patch 'update_tags', id: mona_lisa.id, entity: { tags: 'pretty,smile' }
      expect(response).to be_success
      expect(mona_lisa.reload.tag_list).to eq(['art', 'late', 'pretty', 'smile'])
    end
  end

  context 'as mrossi' do
    before :each do
      current_user User.find_by!(name: 'mrossi')
    end

    it "should restrict moving entities between collections" do
      last_supper = Entity.find_by! name: 'The Last Supper'
      default = Collection.find_by! name: 'default'
      patch :update, id: last_supper.id, entity: { collection_id: default.id }
      expect(response.status).to eq(403)
      expect(json['message']).to match(/moving an entity from one collection/)
    end
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET index' do
      get 'index'
      expect_collection_response count: 7

      get 'index', kind_id: Kind.medium_kind_id
      expect_collection_response count: 2
      expect(json['records'][0]['primary_entities']).to be_nil
      expect(json['records'][1]['primary_entities']).to be_nil

      get 'index', include: 'gallery_data', kind_id: Kind.medium_kind_id
      expect_collection_response count: 2
      expect(json['records'][0]['primary_entities'].size).to eq(1)
      expect(json['records'][1]['primary_entities'].size).to eq(1)

      Kor.settings.update(
        'primary_relations' => [],
        'secondary_relations' => []
      )
      
      get 'index', include: 'gallery_data', kind_id: Kind.medium_kind_id
      expect_collection_response count: 2
      expect(json['records'][0]['primary_entities'].size).to eq(0)
      expect(json['records'][1]['primary_entities'].size).to eq(0)

      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      leonardo = Entity.find_by! name: 'Leonardo'
      get 'index', id: "#{mona_lisa.id},#{leonardo.id}"
      expect(json['records'][0]['name']).to eq('Leonardo')
      expect(json['records'][1]['name']).to eq('Mona Lisa')
    end

    it 'should GET existence' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      leonardo = Entity.find_by! name: 'Leonardo'
      get 'existence', ids: [mona_lisa.id, leonardo.id, 588]
      expect(json).to eq(
        mona_lisa.id.to_s => true,
        leonardo.id.to_s => true,
        '588' => false
      )
    end

    it 'should GET show' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      get 'show', id: mona_lisa.id
      expect(response).to be_success
      expect(json['name']).to eq('Mona Lisa')
      expect(json['relations']).to be_nil

      get 'show', id: mona_lisa.id, include: 'relations,technical'
      expect(response).to be_success
      expect(json['relations']['has been created by']).to eq(1)
      expect(json['relations']['is located in']).to eq(1)
      expect(json['relations']['is related to']).to eq(1)
      expect(json['uuid']).not_to be_nil
    end

    it 'should GET metadata' do
      picture = Kind.medium_kind.entities.first
      get 'metadata', id: picture.id
      expect(response).to be_success
      expect(response.body).to match(/medium/)
      expect(response.body).to match(/Mona Lisa/)
      expect(response.body).to match(/Leonardo/)
    end

    it 'should GET relation_counts' # action still relevant?

    it 'should POST create' do
      group = UserGroup.create! name: 'pretty', user_id: User.admin.id
      entity_params = {
        collection_id: Collection.find_by!(name: 'default').id,
        kind_id: Kind.find_by!(name: 'person').id,
        name: 'Van Gogh',
        dataset: {
          'gnd_id' => '12345'
        },
        synonyms: ["The Earless", "The Sad"],
        properties: [
          { label: 'shoe size', value: "42" },
          { label: 'age', value: "53" }
        ],
        datings_attributes: [
          { label: 'Date of birth', dating_string: '1599' },
          { label: 'Date of death', dating_string: '1688' }
        ]
      }
    
      post 'create', entity: entity_params, user_group_name: group.name
      expect_created_response
      van_gogh = Entity.find_by!(name: 'Van Gogh')
      expect(van_gogh.dataset['gnd_id']).to eq('12345')
      expect(van_gogh.synonyms).to eql(['The Earless', 'The Sad'])
      expect(van_gogh.properties).to eq(
        [
          { 'label' => 'shoe size', 'value' => "42" },
          { 'label' => 'age', 'value' => "53" }
        ]
      )
      expect(van_gogh.datings[0].dating_string).to eq('1599')
      expect(van_gogh.datings[1].dating_string).to eq('1688')
      expect(group.reload.entities).to include(van_gogh)
    end

    it "should verify that there is a file for media uploads" do
      post 'create', entity: {
        collection_id: default.id,
        kind_id: Kind.medium_kind.id
      }
      expect(response).not_to be_success
      expect(json['errors']['medium'].size).to eq(1)

      post :create, entity: {
        collection_id: Collection.first.id,
        name: "Some name",
        kind_id: Kind.medium_kind.id,
        medium_attributes: {}
      }
      expect(response).not_to be_success
    end

    it "should verify file size when uploading files" do
      Kor.settings["max_file_upload_size"] = 0.2
      file = fixture_file_upload("image_c.jpg", 'image/jpeg')

      post :create, entity: {
        kind_id: Kind.medium_kind.id,
        collection_id: default.id,
        medium_attributes: { image: file }
      }
      expect(response.status).to eq(422)
      expect(json['errors']['medium.image_file_size'].size).to eq(1)
    end

    it 'should verify that there are no duplicates' do
      file = fixture_file_upload("image_a.jpg", 'image/jpeg')
      post 'create', entity: {
        kind_id: Kind.medium_kind.id,
        collection_id: default.id,
        medium_attributes: { image: file }
      }
      expect(response.status).to eq(422)
    end

    it 'should POST create (media)' do
      file = fixture_file_upload("image_c.jpg", 'image/jpeg')
      post 'create', entity: {
        kind_id: Kind.medium_kind.id,
        collection_id: default.id,
        medium_attributes: { image: file }
      }
      expect_created_response
    end

    it 'should POST create (media) and put it into a designated group' do
      file = fixture_file_upload("image_c.jpg", 'image/jpeg')
      post 'create', {
        entity: {
          kind_id: Kind.medium_kind.id,
          collection_id: default.id,
          medium_attributes: { image: file }
        },
        user_group_name: 'today'
      }
      expect_created_response
      today = UserGroup.find_by!(name: 'today')
      expect(today.entities.size).to eq(1)
      expect(today.entities.first).to eq(picture_c)
      expect(today.owner).to eq(admin)
    end

    it 'should POST create (media) and relate id with a designated entity' do
      file = fixture_file_upload("image_c.jpg", 'image/jpeg')
      post 'create', {
        entity: {
          kind_id: Kind.medium_kind.id,
          collection_id: default.id,
          medium_attributes: { image: file }
        },
        target_entity_id: mona_lisa.id,
        relation_name: 'shows'
      }
      expect_created_response
      rels = picture_c.outgoing_relationships
      expect(rels.first.to).to eq(mona_lisa)
      expect(rels.first.relation_name).to eq('shows')
    end

    it 'when a duplicate was found, put it in the designated group' do
      file = fixture_file_upload("image_a.jpg", 'image/jpeg')
      post 'create', {
        entity: {
          kind_id: Kind.medium_kind.id,
          collection_id: default.id,
          medium_attributes: { image: file }
        },
        user_group_name: 'today'
      }
      expect_created_response
      today = UserGroup.find_by!(name: 'today')
      expect(today.entities.size).to eq(1)
      expect(today.entities.first).to eq(picture_a)
    end

    it 'should PATCH update' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      patch 'update', id: mona_lisa.id, entity: { name: 'Mona Liza' }
      expect_updated_response
      expect(mona_lisa.reload.name).to eq('Mona Liza')
    end

    it 'should PATCH update_tags' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      patch 'update_tags', id: mona_lisa.id, entity: { tags: 'pretty,smile' }
      expect(response).to be_success
      expect(mona_lisa.reload.tag_list).to eq(['art', 'late', 'pretty', 'smile'])
    end

    it 'should POST merge' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      last_supper = Entity.find_by! name: 'The Last Supper'
      post 'merge', entity_ids: [mona_lisa.id, last_supper.id], entity: { name: 'Mona Lisa' }
      expect(response).to be_success
      result = Entity.find(json['id'])
      expect(result.name).to eq('Mona Lisa')
      expect(Entity.find_by id: mona_lisa.id).to be_nil
      expect(Entity.find_by id: last_supper.id).to be_nil
    end

    it 'should POST mass_relate' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      last_supper = Entity.find_by! name: 'The Last Supper'
      paris = Entity.find_by! name: 'Paris'
      post 'mass_relate', {
        id: paris.id,
        entity_ids: [mona_lisa.id, last_supper.id],
        relation_name: 'is related to'
      }
      expect(response).to be_success
      expect(paris.outgoing_relationships.by_to_entity(mona_lisa.id).size).to eq(1)
      expect(paris.outgoing_relationships.by_to_entity(last_supper.id).size).to eq(1)
    end

    it 'should not DELETE destroy' do
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      delete 'destroy', id: mona_lisa.id
      expect_deleted_response
      expect(Entity.find_by id: mona_lisa.id).to be_nil
    end

    it "should restrict moving entities between collections" do
      last_supper = Entity.find_by! name: 'The Last Supper'
      default = Collection.find_by! name: 'default'
      patch :update, id: last_supper.id, entity: { collection_id: default.id }
      expect_updated_response
      expect(last_supper.reload.collection_id).to eq(default.id)
    end

    it 'should include facets on demand' do
      leonardo = Entity.find_by! name: 'Leonardo'
      user_group = UserGroup.create! owner: User.admin, name: 'test group'
      user_group.entities << leonardo
      authority_group = AuthorityGroup.create name: 'global test group'
      authority_group.entities << leonardo

      facets = {
        'datings' => 'datings',
        'dataset' => 'dataset',
        'relations' => 'relations',
        'media_relations' => 'media_relations',
        'related' => 'related',
        'synonyms' => 'synonyms',
        'properties' => 'properties',
        'kind' => 'kind',
        'collection' => 'collection',
        'user_groups' => 'user_groups',
        'groups' => 'groups',
        'technical' => 'uuid',
        'degree' => 'degree',
        'users' => 'creator',
        'fields' => 'fields',
        'generators' => 'generators',
        'gallery_data' => 'primary_entities'
      }

      facets.each do |param, key|
        get 'show', id: leonardo.id
        expect(json[key]).to be_nil

        get 'show', id: leonardo.id, include: param
        expect(json[key]).not_to be_nil
      end

      get 'show', id: leonardo.id, include: 'all'

      expect(json['datings']).to be_a(Array)
      expect(json['datings'].size).to eq(1)
      expect(json['datings'].first['dating_string']).to eq('1452 bis 1519')
      expect(json['dataset']).to eq('gnd_id' => '123456789')
      expect(json['relations']['has created']).to eq(2)
      expect(json['media_relations']).to be_empty
      expect(json['related'][0]['to']['name']).to eq('Mona Lisa')
      expect(json['related'][1]['to']['name']).to eq('The Last Supper')
      expect(json['synonyms']).to eq(['Leo'])
      expect(json['properties']).to eq([{ 'label' => 'Epoche', 'value' => 'Renaissance' }])
      expect(json['kind']['name']).to eq('person')
      expect(json['collection']['name']).to eq('Default')
      expect(json['user_groups'].size).to eq(1)
      expect(json['user_groups'][0]['name']).to eq('test group')
      expect(json['groups'].size).to eq(1)
      expect(json['groups'][0]['name']).to eq('global test group')
      expect(json['groups'][0]['name']).to eq('global test group')
      expect(json['uuid']).not_to be_nil
      expect(json['created_at']).not_to be_nil
      expect(json['updated_at']).not_to be_nil
      expect(json['no_name_statement']).not_to be_nil
      expect(json['degree']).to eq(2)
      expect(json['creator']['name']).to eq(leonardo.creator.name)
      expect(json['updater']['name']).to eq(leonardo.updater.name)
      expect(json['fields'].size).to eq(2)
      expect(json['fields'][0]['name']).to eq('gnd_id')
      expect(json['generators'].size).to eq(1)
      expect(json['generators'][0]['name']).to eq('gnd')
    end

    it "should merge two entities while not messing up the dataset" do
      works = Kind.find_by! name: 'work'
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      other_mona_lisa = FactoryGirl.create :mona_lisa, name: 'Monalisa', dataset: {
        gnd: '123456',
        google_maps: 'Deutsche Straße 12, Frankfurt'
      }    

      entity_ids = [
        Entity.find_by_name("Mona Lisa").id,
        Entity.find_by_name("Monalisa").id
      ]

      post 'merge', entity_ids: entity_ids, entity: {
        name: 'Mona Lisa',
        kind_id: works.id,
        dataset: {
          viaf_id: '1234'
        }
      }
      expect(response).to be_success

      expect(Entity.count).to eq(7)
      expect(Entity.with_deleted.count).to eq(9)
      mona_lisa = Entity.find_by name: 'Mona Lisa'
      expect(mona_lisa).not_to be_nil
      expect(mona_lisa.dataset).to eq({ 'viaf_id' => '1234' })
    end

    it "should merge two images while not messing up the groups" do
      picture_a = Entity.media[0]
      picture_b = Entity.media[1]
      entity_ids = [picture_a.id, picture_b.id]
      
      group_1 = AuthorityGroup.create(name: 'group 1')
      group_1.add_entities(picture_a)
      group_1.add_entities(picture_b)

      nice = UserGroup.find_by! name: 'nice'
      lecture = AuthorityGroup.find_by! name: 'lecture'
         
      post 'merge', entity_ids: entity_ids, entity: {
        medium_id: picture_a.medium_id
      }
      expect(response).to be_success
      expect(Entity.all).not_to include(picture_b)
      
      expect(picture_a.authority_groups.count).to eq(2)
      expect(picture_a.authority_groups).to include(group_1, lecture)
      expect(picture_a.user_groups).to eq([nice])
    end

    it "should merge entities while not loosing comments" do
      works = Kind.find_by! name: 'work'
      mona_lisa = Entity.find_by! name: 'Mona Lisa'
      mona_lisa.update comment: 'comment 1'
      other_mona_lisa = FactoryGirl.create :mona_lisa, {
        name: 'Monalisa',
        comment: 'comment 2',
        dataset: {
          gnd: '123456',
          google_maps: 'Deutsche Straße 12, Frankfurt'
        }
      }

      post 'merge', entity_ids: [mona_lisa.id, other_mona_lisa.id], entity: { 
        name: 'Mona Lisa', 
        comment: 'comment 1',
        kind_id: works.id
      }
      expect(response).to be_success
        
      expect(Entity.find_by_name('Mona Lisa').comment).to eql("comment 1")
    end

    it "should merge two entities with datings" do
      works = Kind.find_by! name: 'work'
      leonardo = Entity.find_by! name: 'Leonardo'
      other_leonardo = FactoryGirl.create :leonardo, {
        name: 'Leonardo da Vinci',
        datings: [EntityDating.new(label: 'Lifespan', dating_string: '1877')]
      }

      post 'merge', entity_ids: [leonardo.id, other_leonardo.id], entity: { 
        :name => 'Leonardo', 
        :kind_id => works.id,
      }
      expect(response).to be_success

      leonardo = Entity.find_by! name: 'Leonardo'
      expect(Entity.count).to eq(7)
      expect(leonardo.datings.count).to eq(2)    
    end
  end

  it "should not show the recent entities without edit rights" # capybara
  it "should show the recent entities with edit rights" # capybara
  it "should not show the invalid entities without delete rights" # capybara
  it "should show the invalid entities with delete rights" # capybara
  it 'should return validation errors'
end
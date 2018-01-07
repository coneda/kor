require 'rails_helper'

describe DirectedRelationshipsController, type: :controller do

  include DataHelper

  render_views

  before :each do
    request.headers['accept'] = 'application/json'
  end

  it "should list all relationships" do
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
    Kor::Auth.grant default, :view, :to => [admins, students]
    Kor::Auth.grant side, :view, :to => [admins]

    get :index
    expect(response.status).to eq(403)

    guest = FactoryGirl.create :guest

    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['total']).to eq(0)

    current_user = jdoe
    allow_any_instance_of(described_class).to receive(:current_user) do
      current_user
    end

    get :index
    expect(JSON.parse(response.body)['records'].size).to eq(10)

    get :index, :page => 1
    expect(JSON.parse(response.body)['records'].size).to eq(10)

    get :index, :page => 3
    expect(JSON.parse(response.body)['records'].size).to eq(2)

    get :index, :per_page => 30
    expect(JSON.parse(response.body)['records'].size).to eq(22)

    get :index, :per_page => 22
    expect(JSON.parse(response.body)['records'].size).to eq(22)

    current_user = admin

    get :index, :per_page => 30
    expect(JSON.parse(response.body)['records'].size).to eq(26)

    get :index, :per_page => 20, :entity_id => side_artist.id
    expect(JSON.parse(response.body)['records'].size).to eq(1)

    get :index, per_page: 20, relation_name: 'shows'
    expect(JSON.parse(response.body)['records'].size).to eq(1)
  end

  it "should respond with a single directed relationship" do
    default_setup relationships: true

    directed_relationship = Relationship.first.normal
    get :show, id: directed_relationship.id
    expect(response.status).to eq(403)

    get :show, id: directed_relationship.id, api_key: @admin.api_key
    expect(response.status).to eq(200)
    data = JSON.parse(response.body)
    expect(data['id']).to eq(directed_relationship.id)
  end

  it 'should allow for multiple ids' do
    default_setup relationships: true
    FactoryGirl.create :relation
    FactoryGirl.create :is_located_at
    paris = FactoryGirl.create :paris
    Relationship.relate_and_save @mona_lisa, 'is related to', @last_supper
    Relationship.relate_and_save @mona_lisa, 'is located at', paris

    allow_any_instance_of(described_class).to receive(:current_user) do
      User.admin
    end

    get :index, from_kind_id: @people.id
    expect(JSON.parse(response.body)['total']).to eq(2)

    get :index, from_kind_id: @works.id
    expect(JSON.parse(response.body)['total']).to eq(5)

    get :index, from_kind_id: "#{@works.id},#{@people.id}"
    expect(JSON.parse(response.body)['total']).to eq(7)

    get :index, to_kind_id: @people.id
    expect(JSON.parse(response.body)['total']).to eq(2)

    get :index, to_kind_id: @works.id
    expect(JSON.parse(response.body)['total']).to eq(5)

    get :index, to_kind_id: "#{@works.id},#{@people.id}"
    expect(JSON.parse(response.body)['total']).to eq(7)

    get :index, from_entity_id: "#{@last_supper.id},#{paris.id}"
    expect(JSON.parse(response.body)['total']).to eq(3)

    get :index, to_entity_id: "#{@last_supper.id},#{paris.id}"
    expect(JSON.parse(response.body)['total']).to eq(3)
  end

  it 'should include properties when requested' do
    default_setup
    Relationship.relate_and_save(@leonardo, 'has created', @mona_lisa, [
      'perhaps'
    ])

    get :index, api_key: User.admin.api_key, include: 'properties'
    rs_data = JSON.parse(response.body)['records'].first
    expect(rs_data['properties']).to eq(['perhaps'])
  end

end

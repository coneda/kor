require 'rails_helper'

describe DirectedRelationshipsController, type: :controller do

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
    default.grant :view, :to => [admins, students]
    side.grant :view, :to => [admins]

    get :index
    expect(response.status).to eq(401)

    guest = FactoryGirl.create :guest

    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body).size).to eq(0)

    current_user = jdoe
    allow_any_instance_of(described_class).to receive(:current_user) do
      current_user
    end

    get :index
    expect(JSON.parse(response.body).size).to eq(10)

    get :index, :page => 1
    expect(JSON.parse(response.body).size).to eq(10)

    get :index, :page => 3
    expect(JSON.parse(response.body).size).to eq(2)

    get :index, :per_page => 30
    expect(JSON.parse(response.body).size).to eq(22)

    get :index, :per_page => 22
    expect(JSON.parse(response.body).size).to eq(22)

    current_user = admin

    get :index, :per_page => 30
    expect(JSON.parse(response.body).size).to eq(26)

    get :index, :per_page => 20, :entity_id => side_artist.id
    expect(JSON.parse(response.body).size).to eq(1)

    get :index, per_page: 20, relation_name: 'shows'
    expect(JSON.parse(response.body).size).to eq(1)
  end

  it "should response with a single directed relationship"

end
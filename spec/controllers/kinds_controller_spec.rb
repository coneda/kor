require 'rails_helper'

RSpec.describe KindsController, type: :controller do

  render_views

  def data
    JSON.parse(response.body)
  end

  before :each do
    request.headers['accept'] = 'application/json'
    @media = FactoryGirl.create :media
    @admin = FactoryGirl.create :admin
  end

  it 'should retrieve a single kind' do
    get :show, id: @media.id
    expect(response.status).to eq(200)
    expect(data['name']).to eq('Medium')
  end

  it 'should retrieve all kinds' do
    @people = FactoryGirl.create :people

    get :index
    expect(data['records'].size).to eq(2)
  end

  context 'as admin' do

    before :each do
      request.headers['accept'] = 'application/json'
      request.headers['api_key'] = @admin.api_key
    end

    it 'should create a kind' do
      post :create, kind: {
        name: 'person',
        plural_name: 'people'
      }
      expect(response.status).to eq(200)
      expect(data['record']['id']).not_to be_nil
      expect(data['message']).to eq('entity type has been created')
    end

    it 'should create a sub kind' do
      post :create, kind: {
        name: 'person',
        plural_name: 'people',
        parent_ids: [@media.id]
      }
      expect(response.status).to eq(200)
      expect(data['record']['parent_ids']).to eq([@media.id])
    end

    it 'should update a kind' do
      @people = FactoryGirl.create :people

      patch :update, id: @people.id, kind: {
        name: 'artists',
        parent_ids: [@media.id]
      }
      expect(response.status).to eq(200)
      expect(data['record']['name']).to eq('artists')
      expect(data['record']['parent_ids']).to eq([@media.id])
    end

    it 'should move a kind' do
      @people = FactoryGirl.create :people
      @works = FactoryGirl.create :works, parent_ids: [@people.id]

      patch :update, id: @works.id, kind: {
        parent_ids: [@media.id]
      }
      expect(response.status).to eq(200)
      expect(data['record']['parent_ids']).to eq([@media.id])
    end

    it 'should render errors when the plural name is missing' do
      post :create, kind: {
        name: 'person'
      }
      expect(response.status).to eq(406)
      expect(data['errors']['plural_name']).to include('has to be filled in')
    end

    it 'should ignore addition of non-existing parents' do
      @people = FactoryGirl.create :people

      patch :update, id: @people.id, kind: {parent_ids: 99}
      expect(response.status).to eq(200)
      expect(data['record']['parent_ids']).to be_empty
    end

    it 'should not delete parents as long as they have chrildren' do
      @people = FactoryGirl.create :people
      @works = FactoryGirl.create :works, parent_ids: @people.id

      delete :destroy, id: @people.id
      expect(response.status).to eq(406)
      expect(data['message']).to eq("kinds with children can't be deleted")
    end

  end

end
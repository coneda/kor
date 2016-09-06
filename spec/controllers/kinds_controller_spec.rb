require 'rails_helper'

RSpec.describe KindsController, type: :controller do

  render_views

  before :each do
    request.headers['accept'] = 'application/json'
  end
  
  context 'index and show' do
    it 'should deny access without a guest account' do
      works = FactoryGirl.create :works

      get :index
      expect(response.status).to eq(403)

      get :show, id: works.id
      expect(response.status).to eq(403)
    end

    it "should grant access with a guest account" do
      media = FactoryGirl.create :media
      works = FactoryGirl.create :works
      guest = FactoryGirl.create :guest

      get :index
      expect(response.status).to eq(200)

      get :show, id: works.id
      expect(response.status).to eq(200)
    end
  end

  context 'create, update and destroy' do
    it "should deny the update without authentication" do
      works = FactoryGirl.create :works

      patch :update, id: works.id, kind: {plural_name: 'artworks'}
      expect(response.status).to eq(403)
    end

    it "should deny the update without admin rights" do
      works = FactoryGirl.create :works
      jdoe = FactoryGirl.create :jdoe

      patch :create,
        api_key: jdoe.api_key,
        id: works.id,
        kind: {name: 'artwork', plural_name: 'artworks'}
      expect(response.status).to eq(403)

      patch :update,
        api_key: jdoe.api_key,
        id: works.id,
        kind: {plural_name: 'artworks'}
      expect(response.status).to eq(403)

      patch :destroy, api_key: jdoe.api_key, id: works.id
      expect(response.status).to eq(403)
    end

    it "should allow the update with admin rights" do
      works = FactoryGirl.create :works
      admin = FactoryGirl.create :admin

      patch :create,
        api_key: admin.api_key,
        id: works.id,
        kind: {name: 'artwork', plural_name: 'artworks'}
      expect(response.status).to eq(200)

      patch :update,
        api_key: admin.api_key,
        id: works.id,
        kind: {plural_name: 'artworks'}
      expect(response.status).to eq(200)

      patch :destroy, api_key: admin.api_key, id: works.id
      expect(response.status).to eq(200)
    end
  end

  context 'JSON API' do

    before :each do
      @media = FactoryGirl.create :media
      @admin = FactoryGirl.create :admin

      request.headers['accept'] = 'application/json'
      request.headers['api_key'] = @admin.api_key
    end

    it 'should retrieve all roots' do
      @people = FactoryGirl.create :people

      get :index
      data = JSON.parse(response.body)
      expect(data['records'].size).to eq(2)

      @people.move_to_child_of(@media)

      get :index
      data = JSON.parse(response.body)
      expect(data['records'].size).to eq(1)
    end

    it 'should retrieve sub kinds' do
      @people = FactoryGirl.create :people
      @people.move_to_child_of(@media)

      get :index, parent_id: @media.id
      data = JSON.parse(response.body)
      expect(data['records'].size).to eq(1)

      get :index, parent_id: @people.id
      data = JSON.parse(response.body)
      expect(data['records'].size).to eq(0)
    end

    it 'should create a kind' do
      post :create, kind: {
        name: 'person',
        plural_name: 'people'
      }
      expect(response.status).to eq(200)
      data = JSON.parse(response.body)
      expect(data['record']['id']).not_to be_nil
      expect(data['message']).to eq('entity type has been created')
    end

    it 'should create a sub kind' do
      post :create, kind: {
        name: 'person',
        plural_name: 'people',
        parent_id: @media.id
      }
      expect(response.status).to eq(200)
      data = JSON.parse(response.body)
      expect(data['record']['parent_id']).to eq(@media.id)
    end

    it 'should update a kind' do
      @people = FactoryGirl.create :people

      patch :update, id: @people.id, kind: {
        name: 'artists',
        parent_id: @media.id
      }
      expect(response.status).to eq(200)
      data = JSON.parse(response.body)
      expect(data['record']['name']).to eq('artists')
      expect(data['record']['parent_id']).to eq(@media.id)
    end

    it 'should move a kind' do
      @people = FactoryGirl.create :people
      @works = FactoryGirl.create :works, parent_id: @people.id

      patch :update, id: @works.id, kind: {
        parent_id: @media.id
      }
      expect(response.status).to eq(200)
      data = JSON.parse(response.body)
      expect(data['record']['parent_id']).to eq(@media.id)
    end

    it 'should render errors when the plural name is missing' do
      post :create, kind: {
        name: 'person',
      }
      expect(response.status).to eq(406)
      data = JSON.parse(response.body)
      expect(data['errors']['plural_name']).to include('has to be filled in')
    end

    it 'should render errors when trying to move to a non-existing parent' do
      @people = FactoryGirl.create :people

      patch :update, id: @people.id, kind: {parent_id: 99}
      expect(response.status).to eq(406)
      data = JSON.parse(response.body)
      expect(data['errors']['parent']).to include("doesn't exist")
    end

    it 'should delete all chrildren along with their parent' do
      @people = FactoryGirl.create :people
      @works = FactoryGirl.create :works, parent_id: @people.id

      delete :destroy, id: @people.id
      expect(response.status).to eq(200)
      data = JSON.parse(response.body)
      expect(data['record']['name']).to eq('person')
      expect(Kind.count).to eq(1)
    end

  end

end
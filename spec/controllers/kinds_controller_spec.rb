require 'rails_helper'

RSpec.describe KindsController, type: :controller do

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

    it 'should deny deleting the medium kind' do
      media = FactoryGirl.create :media

      delete :destroy, id: media.id
      expect(response.status).to eq(403)
    end
  end

end
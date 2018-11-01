require 'rails_helper'

RSpec.describe CredentialsController, type: :controller do
  render_views

  it 'should not GET index' do
    get :index
    expect(response).to be_forbidden
  end

  it 'should GET show' do
    get :show, id: Credential.find_by!(name: 'students').id
    expect(response).to be_forbidden
  end

  it 'should not POST create' do
    post :create, credential: {name: 'teachers'}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    id = Credential.find_by!(name: 'students').id
    patch :update, id: id, credential: {name: 'teachers'}
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    id = Credential.find_by!(name: 'students').id
    delete :destroy, id: id
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 3
    end

    it 'should GET show' do
      get :show, id: Credential.find_by!(name: 'students').id
      expect(response).to be_success
      expect(json['name']).to eq('students')
      expect(json['counts']).to be_nil
    end

    it 'should GET show with additions' do
      id = Credential.find_by!(name: 'students').id
      get :show, id: id, include: 'counts'
      expect(json['user_count']).to eq(1)
    end

    it 'should POST create' do
      post :create, credential: {name: 'teachers'}
      expect_created_response
      c = Credential.find_by!(name: 'teachers')
    end

    it 'should PATCH update' do
      id = Credential.find_by!(name: 'students').id
      patch :update, id: id, credential: {name: 'teachers'}
      expect_updated_response
      agc = Credential.find(id)
      expect(agc.name).to eq('teachers')
    end

    it 'should DELETE destroy' do
      students = Credential.find_by!(name: 'students')
      delete :destroy, id: students.id
      expect_deleted_response
      expect(Credential.find_by(id: students.id)).to be_nil
    end
  end
end
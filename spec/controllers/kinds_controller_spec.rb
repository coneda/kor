require 'rails_helper'

RSpec.describe KindsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 5
  end

  it 'should GET show' do
    get :show, id: Kind.medium_kind_id
    expect(response).to be_success
    expect(json['name']).to eq('medium')
    expect(json['settings']).to be_nil
  end

  it 'should GET show with additions' do
    get :show, id: Kind.medium_kind_id, include: 'settings'
    expect(response).to be_success
    expect(json['name']).to eq('medium')
    expect(json['settings']).to be_a(Hash)
  end

  it 'should not POST create' do
    post :create, kind: {name: 'literatur', plural_name: 'literature'}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    person = Kind.find_by!(name: 'person')
    patch :update, id: person.id, person: {plural_name: 'persons'}
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    kind = Kind.find_by! name: 'person'
    delete :destroy, id: kind.id
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      post :create, kind: {name: 'city', plural_name: 'cities'}
      expect_created_response
      c = Kind.find_by!(name: 'city')
    end

    it 'should PATCH update' do
      id = Kind.find_by!(name: 'person').id
      patch :update, id: id, kind: {plural_name: 'persons'}
      expect_updated_response
      expect(Kind.find(id).plural_name).to eq('persons')
    end

    it 'should not DELETE destroy (medium kind)' do
      delete :destroy, id: Kind.medium_kind_id
      expect(response).to be_client_error
      expect(json['message']).to match(/medium kind cannot be removed/)
    end

    it 'should not DELETE destroy (kind with entities)' do
      kind = Kind.find_by! name: 'location'
      delete :destroy, id: kind.id
      expect(response).to be_client_error
      expect(json['message']).to match(/it still has entities/)
    end

    it 'should not DELETE destroy (kind with children)' do
      locations = Kind.find_by! name: 'location'
      cities = Kind.create! name: 'city', plural_name: 'cities', parent_ids: [locations.id]
      delete :destroy, id: locations.id
      expect(response).to be_client_error
      expect(json['message']).to match(/kinds with children can't be deleted/)
    end

    it 'should DELETE destroy' do
      kind = Kind.find_by! name: 'location'
      kind.entities.destroy_all
      delete :destroy, id: kind.id
      expect_deleted_response
      expect(Kind.find_by(id: kind.id)).to be_nil
    end
  end
end
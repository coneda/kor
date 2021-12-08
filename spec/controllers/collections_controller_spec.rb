require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 0
  end

  it 'should not GET show' do
    get :show, params: {id: Collection.find_by!(name: 'private').id}
    expect(response).to be_forbidden
  end

  it 'should not POST create' do
    post :create, params: {collection: {name: 'private'}}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    id = Collection.find_by!(name: 'private').id
    patch :update, params: {
      id: id, collection: {name: 'confidential'}
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    id = Collection.find_by!(name: 'private').id
    delete :destroy, params: {id: id}
    expect(response).to be_forbidden
  end

  it 'should not POST merge' do
    id = Collection.find_by!(name: 'default').id
    other_id = Collection.find_by!(name: 'private').id
    post :merge, params: {id: id, collection_id: other_id}
    expect(response).to be_forbidden
  end

  it 'should not PATCH entities' do
    id = Collection.find_by!(name: 'private').id
    entity_ids = [mona_lisa.id, leonardo.id]
    patch :entities, params: {id: id, entity_ids: entity_ids}
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 2
    end

    it 'should GET show' do
      get :show, params: {id: Collection.find_by!(name: 'default').id}
      expect(response).to be_success
      expect(json['name']).to eq('Default')
      expect(json['permissions']).to be_nil
    end

    it 'should GET show with additions' do
      id = Collection.find_by!(name: 'default').id
      get :show, params: {id: id, include: 'permissions'}
      expect(json['permissions']).to be_a(Hash)
    end

    it 'should POST create' do
      post :create, params: {collection: {name: 'confidential'}}
      expect_created_response
      Collection.find_by!(name: 'confidential')
    end

    it 'should PATCH update' do
      id = Collection.find_by!(name: 'private').id
      patch :update, params: {id: id, collection: {name: 'old private'}}
      expect_updated_response
      agc = Collection.find(id)
      expect(agc.name).to eq('old private')
    end

    it 'should not DELETE destroy (non-empty collection)' do
      id = Collection.find_by!(name: 'private').id
      delete :destroy, params: {id: id}
      expect(response).to be_client_error
      expect(json['message']).to match(/it is not empty/)
    end

    it 'should DELETE destroy (empty collection)' do
      priv = Collection.find_by!(name: 'private')
      priv.entities.destroy_all
      delete :destroy, params: {id: priv.id}
      expect_deleted_response
      expect(Collection.find_by(id: priv.id)).to be_nil
    end

    it 'should POST merge' do
      id = Collection.find_by!(name: 'default').id
      other_id = Collection.find_by!(name: 'private').id
      post :merge, params: {id: id, collection_id: other_id}
      expect(response).to be_success
      expect(json['message']).to match(/the domains have been merged/)
      # it doesn't actually delete the source domain
      expect(Collection.count).to eq(2)
      expect(Collection.find_by!(name: 'Default').entities.count).to eq(0)
      expect(Collection.find_by!(name: 'private').entities.count).to eq(7)
    end

    it 'should PATCH entities' do
      id = Collection.find_by!(name: 'private').id
      entity_ids = [mona_lisa.id, leonardo.id]
      patch :entities, params: {id: id, entity_ids: entity_ids}

      expect(mona_lisa.collection_id).to be(id)
      expect(leonardo.collection_id).to be(id)
    end
  end
end

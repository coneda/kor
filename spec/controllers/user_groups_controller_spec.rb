require 'rails_helper'

RSpec.describe UserGroupsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect(response).to be_client_error
  end

  it 'should GET shared' do
    get :shared
    expect_collection_response total: 0

    group = UserGroup.find_by! name: 'nice'
    group.update shared: true

    get :shared
    expect_collection_response total: 1
  end

  it 'should not GET download_images' do
    group = UserGroup.find_by! name: 'nice'
    get :download_images, id: group.id
    expect(response).to be_client_error
  end

  it 'should not GET show' do
    group = UserGroup.find_by! name: 'nice'
    get :show, id: group.id
    expect(response).to be_forbidden
  end

  it 'should not POST create' do
    post :create, user_group: { name: 'interesting' }
    expect(response).to be_client_error
  end

  it 'should not PATCH update' do
    group = UserGroup.find_by! name: 'nice'
    patch :update, id: group.id, user_group: { name: 'interesting' }
    expect(response).to be_client_error
  end

  it 'should not DELETE destroy' do
    group = UserGroup.find_by! name: 'nice'
    delete :destroy, id: group.id
    expect(response).to be_client_error
  end

  it 'should not PATCH share' do
    group = UserGroup.find_by! name: 'nice'
    patch :share, id: group.id
    expect(response).to be_client_error
  end

  it 'should not PATCH unshare' do
    group = UserGroup.find_by! name: 'nice'
    group.update shared: true
    patch :unshare, id: group.id
    expect(response).to be_client_error
  end

  it 'should not POST add_to' do
    post 'add_to', id: nice.id, entity_ids: [mona_lisa.id]
    expect(response).to be_client_error
  end

  it 'should not POST remove_from' do
    nice.add_entities mona_lisa
    post 'remove_from', id: nice.id, entity_ids: [mona_lisa.id]
    expect(response).to be_client_error
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 1
    end

    it 'should not GET show (foreign group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update owner: User.admin
      get :show, id: group.id
      expect(response).to be_forbidden
    end

    it 'should GET show (own group)' do
      group = UserGroup.find_by! name: 'nice'
      get :show, id: group.id
      expect(response).to be_success
      expect(json['name']).to eq('nice')
      expect(json['owner']).to be_nil
    end

    it 'should GET show with additions' do
      group = UserGroup.find_by! name: 'nice'
      get :show, id: group.id, include: 'owner'
      expect(response).to be_success
      expect(json['owner']).to be_a(Hash)
    end

    it 'should GET download_images' do
      group = UserGroup.find_by! name: 'nice'
      get :download_images, id: group.id
      dl = Download.first
      expect(response).to redirect_to("/downloads/#{dl.uuid}")
    end

    it 'should POST create' do
      post :create, user_group: { name: 'pretty' }
      expect_created_response
      UserGroup.find_by!(name: 'pretty')
    end

    it 'should not PATCH update (foreign group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update owner: User.admin
      patch :update, id: group.id, user_group: { name: 'pretty' }
      expect(response).to be_client_error
    end

    it 'should PATCH update (own group)' do
      group = UserGroup.find_by! name: 'nice'
      patch :update, id: group.id, user_group: { name: 'pretty' }
      expect_updated_response
      expect(group.reload.name).to eq('pretty')
    end

    it 'should not DELETE destroy (foreign group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update owner: User.admin
      delete :destroy, id: group.id
      expect(response).to be_client_error
    end

    it 'should not DELETE destroy (own group)' do
      group = UserGroup.find_by! name: 'nice'
      delete :destroy, id: group.id
      expect(response).to be_success
      expect(UserGroup.find_by id: group.id).to be_nil
    end

    it 'should not PATCH share (foreign group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update owner: User.admin
      patch :share, id: group.id
      expect(response).to be_client_error
    end

    it 'should not PATCH unshare (foreign group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update owner: User.admin, shared: true
      patch :unshare, id: group.id
      expect(response).to be_client_error
    end

    it 'should not POST add_to (foreign group)' do
      nice.update owner: User.admin
      post 'add_to', id: nice.id, entity_ids: [mona_lisa.id]
      expect(response).to be_client_error
    end

    it 'should not POST remove_from (foreign group)' do
      nice.add_entities mona_lisa
      nice.update owner: User.admin
      post 'remove_from', id: nice.id, entity_ids: [mona_lisa.id]
      expect(response).to be_client_error
    end

    it 'should PATCH share (own group)' do
      group = UserGroup.find_by! name: 'nice'
      patch :share, id: group.id
      expect(response).to be_success
    end

    it 'should PATCH unshare (own group)' do
      group = UserGroup.find_by! name: 'nice'
      group.update shared: true
      patch :unshare, id: group.id
      expect(response).to be_success
    end

    it 'should POST add_to (own group)' do
      post :add_to, id: nice.id, entity_ids: [mona_lisa.id]
      expect(response).to be_success
      expect(nice.entities).to include(mona_lisa)
    end

    it 'should POST remove_from (own group)' do
      post :remove_from, id: nice.id, entity_ids: [picture_a.id]
      expect(response).to be_success
      expect(nice.entities).not_to include(picture_a)
    end
  end

  # it 'should put all entities within a group into the clipboard' do
  #   leonardo = Entity.find_by(name: 'Leonardo da Vinci')
  #   mona_lisa = Entity.find_by(name: 'Mona Lisa')

  #   group = FactoryGirl.create :user_group, owner: User.admin
  #   group.add_entities [mona_lisa, leonardo]

  #   get :mark, id: group.id

  #   expect(User.admin.clipboard).to include(mona_lisa.id, leonardo.id)
  # end
end

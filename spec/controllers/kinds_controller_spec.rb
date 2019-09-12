require 'rails_helper'

RSpec.describe KindsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 5
  end

  it 'should GET show' do
    get :show, params: {id: Kind.medium_kind_id}
    expect(response).to be_success
    expect(json['name']).to eq('medium')
    expect(json['settings']).to be_nil
  end

  it 'should GET show with additions' do
    get :show, params: {id: Kind.medium_kind_id, include: 'settings'}
    expect(response).to be_success
    expect(json['name']).to eq('medium')
    expect(json['distinct_name_label']).to be_a(String)
  end

  it 'should not POST create' do
    post :create, params: {
      kind: {name: 'literatur', plural_name: 'literature'}
    }
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    person = Kind.find_by!(name: 'person')
    patch :update, params: {
      id: person.id, person: {plural_name: 'persons'}
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    kind = Kind.find_by! name: 'person'
    delete :destroy, params: {id: kind.id}
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      post :create, params: {kind: {name: 'city', plural_name: 'cities'}}
      expect_created_response
      Kind.find_by!(name: 'city')
    end

    it 'should PATCH update' do
      id = Kind.find_by!(name: 'person').id
      patch :update, params: {id: id, kind: {plural_name: 'persons'}}
      expect_updated_response
      expect(Kind.find(id).plural_name).to eq('persons')
    end

    it 'should not DELETE destroy (medium kind)' do
      delete :destroy, params: {id: Kind.medium_kind_id}
      expect(response).to be_client_error
      expect(json['message']).to match(/medium kind can't be removed/)
    end

    it 'should not DELETE destroy (kind with entities)' do
      kind = Kind.find_by! name: 'location'
      delete :destroy, params: {id: kind.id}
      expect(response).to be_client_error
      expect(json['message']).to match(/it still has entities/)
    end

    it 'should not DELETE destroy (kind with children)' do
      locations = Kind.find_by! name: 'location'
      Kind.create! name: 'city', plural_name: 'cities', parent_ids: [locations.id]
      delete :destroy, params: {id: locations.id}
      expect(response).to be_client_error
      expect(json['message']).to match(/kinds with children can't be deleted/)
    end

    it 'should DELETE destroy' do
      kind = Kind.find_by! name: 'location'
      kind.entities.destroy_all
      delete :destroy, params: {id: kind.id}
      expect_deleted_response
      expect(Kind.find_by(id: kind.id)).to be_nil
    end

    it 'should create a sub kind' do
      post 'create', params: {
        kind: {
          name: 'artist',
          plural_name: 'artists',
          parent_ids: [people.id]
        }
      }
      expect_created_response
      expect(Kind.find_by!(name: 'artist').parent_ids).to eq([people.id])
    end

    it 'should move a kind' do
      works.update parent_ids: [people.id]

      patch 'update', params: {
        id: works.id, kind: {parent_ids: [media.id]}
      }
      expect(response.status).to eq(200)
      expect(works.reload.parent_ids).to eq([media.id])
    end
  end
end

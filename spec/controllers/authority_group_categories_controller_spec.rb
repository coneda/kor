require 'rails_helper'

RSpec.describe AuthorityGroupCategoriesController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 1
  end

  it 'should GET show' do
    get :show, id: AuthorityGroupCategory.find_by!(name: 'archive').id
    expect(response).to be_success
    expect(json['name']).to eq('archive')
    expect(json['ancestors']).to be_nil
  end

  it 'should GET flat' do
    id = AuthorityGroupCategory.find_by!(name: 'archive').id
    AuthorityGroupCategory.create name: 'sub archive', parent_id: id
    get :flat
    expect_collection_response
    names = json['records'].map{|e| e['name']}
    expect(names).to include('archive', 'sub archive')
  end

  it 'should GET show with additions' do
    id = AuthorityGroupCategory.find_by!(name: 'archive').id
    get :show, id: id, include: 'ancestors'
    expect(json['ancestors']).to be_a(Array)
  end

  it 'should not POST create' do
    post :create, authority_group_category: {name: 'seminar 2018'}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    id = AuthorityGroupCategory.find_by!(name: 'archive').id
    patch :update, id: id, authority_group_category: {name: 'professor'}
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    id = AuthorityGroupCategory.find_by!(name: 'archive').id
    delete :destroy, id: id
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      agc = AuthorityGroupCategory.find_by!(name: 'archive')
      post :create, authority_group_category: {
        name: 'professor',
        parent_id: agc.id
      }
      expect_created_response
      ag = AuthorityGroupCategory.find_by!(name: 'professor')
      expect(ag.parent).to eq(agc)
    end

    it 'should PATCH update' do
      id = AuthorityGroupCategory.find_by!(name: 'archive').id
      patch :update, id: id, authority_group_category: {name: 'old archive'}
      expect_updated_response
      agc = AuthorityGroupCategory.find(id)
      expect(agc.name).to eq('old archive')
    end

    it 'should DELETE destroy' do
      id = AuthorityGroupCategory.find_by!(name: 'archive').id
      delete :destroy, id: id
      expect_deleted_response
      expect(AuthorityGroupCategory.find_by(id: id)).to be_nil
    end
  end
end
require 'rails_helper'

RSpec.describe AuthorityGroupsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 2
  end

  it 'should GET show' do
    get :show, id: AuthorityGroup.find_by!(name: 'seminar').id
    expect(response).to be_success
    expect(json['name']).to eq('seminar')
    expect(json['created_at']).to be_nil
  end

  it 'should GET show with additions' do
    id = AuthorityGroup.find_by!(name: 'seminar').id
    get :show, id: id, include: 'technical'
    expect(Time.parse json['created_at']).to be < Time.now
  end

  it 'should GET download_images' do
    get :download_images, id: AuthorityGroup.find_by!(name: 'lecture').id
    expect(response).to be_success
    # guest is not allowed to see the particular entity
    expect(json['message']).to match(/no entities to download/)
  end

  it 'should not POST create' do
    post :create, authority_group: {name: 'seminar 2018'}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    id = AuthorityGroup.find_by!(name: 'seminar').id
    patch :update, id: id, authority_group: {name: 'seminar 2018'}
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    id = AuthorityGroup.find_by!(name: 'seminar').id
    delete :destroy, id: id
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET download_images' do
      get :download_images, id: AuthorityGroup.find_by!(name: 'lecture').id
      uuid = Download.first.uuid
      expect(response).to redirect_to("/downloads/#{uuid}")
    end

    it 'should POST create' do
      agc = AuthorityGroupCategory.find_by!(name: 'archive')
      post :create, authority_group: {
        name: 'seminar 2018',
        authority_group_category_id: agc.id
      }
      expect_created_response
      ag = AuthorityGroup.find_by!(name: 'seminar 2018')
      expect(ag.name).to eq('seminar 2018')
      expect(ag.authority_group_category.name).to eq('archive')
    end

    it 'should PATCH update' do
      id = AuthorityGroup.find_by!(name: 'seminar').id
      agc = AuthorityGroupCategory.find_by!(name: 'archive')
      patch :update, id: id, authority_group: {
        name: 'seminar 2018',
        authority_group_category_id: agc.id
      }
      expect_updated_response
      ag = AuthorityGroup.find(id)
      expect(ag.name).to eq('seminar 2018')
      expect(ag.authority_group_category.name).to eq('archive')
    end

    it 'should DELETE destroy' do
      id = AuthorityGroup.find_by!(name: 'seminar').id
      delete :destroy, id: id
      expect_deleted_response
      expect(AuthorityGroup.find_by(id: id)).to be_nil
    end
  end

  # it 'should put all entities within a group into the clipboard' do
  #   current_user User.admin

  #   mona_lisa = Entity.find_by name: 'Mona Lisa'
  #   leonardo = Entity.find_by name: 'Leonardo da Vinci'
  #   group = AuthorityGroup.first
  #   group.add_entities [mona_lisa, leonardo]

  #   get :mark, id: group.id

  #   expect(User.admin.clipboard).to include(mona_lisa.id, leonardo.id)
  # end

end
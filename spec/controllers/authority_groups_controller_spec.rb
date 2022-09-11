require 'rails_helper'

RSpec.describe AuthorityGroupsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 2
  end

  it 'should GET show' do
    get :show, params: {id: AuthorityGroup.find_by!(name: 'seminar').id}
    expect(response).to be_successful
    expect(json['name']).to eq('seminar')
    expect(json['created_at']).to be_nil
  end

  it 'should GET show with additions' do
    id = AuthorityGroup.find_by!(name: 'seminar').id
    get :show, params: {id: id, include: 'technical'}
    expect(Time.parse json['created_at']).to be < Time.now
  end

  it 'should GET download_images' do
    get :download_images, params: {id: lecture.id}
    expect(response).to be_successful
    # guest is not allowed to see the particular entity
    expect(json['message']).to match(/no entities to download/)
  end

  it 'should not POST create' do
    post :create, params: {authority_group: {name: 'seminar 2018'}}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    patch :update, params: {
      id: seminar.id,
      authority_group: {name: 'seminar 2018'}
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    delete :destroy, params: {id: seminar.id}
    expect(response).to be_forbidden
  end

  it 'should not PATCH add_to' do
    patch 'add_to', params: {id: seminar.id, entity_ids: [mona_lisa.id]}
    expect(response).to be_forbidden
  end

  it 'should not PATCH remove_from' do
    patch 'remove_from', params: {
      id: lecture.id, entity_ids: [picture_a.id]
    }
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET download_images' do
      get :download_images, params: {id: lecture.id}
      uuid = Download.first.uuid
      expect(response).to redirect_to("/downloads/#{uuid}")
    end

    # it 'should GET download_images (delayed processing)' do
    #   Kor.settings['max_foreground_group_download_size'] = 0

    #   lecture.entities << picture_a

    #   get :download_images, params: {id: lecture.id}
    #   uuid = Download.first.uuid
    #   expect(response).to redirect_to("/downloads/#{uuid}")
    # end

    it 'should POST create' do
      post :create, params: {
        authority_group: {
          name: 'seminar 2018',
          authority_group_category_id: archive.id
        }
      }
      expect_created_response
      ag = AuthorityGroup.find_by!(name: 'seminar 2018')
      expect(ag.name).to eq('seminar 2018')
      expect(ag.authority_group_category.name).to eq('archive')
    end

    it 'should PATCH update' do
      patch :update, params: {
        id: seminar.id,
        authority_group: {
          name: 'seminar 2018',
          authority_group_category_id: archive.id
        }
      }
      expect_updated_response
      seminar = AuthorityGroup.find_by! name: 'seminar 2018'
      expect(seminar.name).to eq('seminar 2018')
      expect(seminar.authority_group_category.name).to eq('archive')
    end

    it 'should DELETE destroy' do
      delete :destroy, params: {id: seminar.id}
      expect_deleted_response
      expect(AuthorityGroup.find_by(id: json['id'])).to be_nil
    end

    it 'should not POST add_to' do
      post 'add_to', params: {id: seminar.id, entity_ids: [mona_lisa.id]}
      expect(response).to be_successful
      expect(seminar.entities).to include(mona_lisa)
    end

    it 'should not POST remove_from' do
      post 'remove_from', params: {id: lecture.id, entity_ids: [picture_a.id]}
      expect(response).to be_successful
      expect(lecture.entities).not_to include(picture_a)
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

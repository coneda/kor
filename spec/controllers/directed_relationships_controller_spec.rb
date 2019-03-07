require 'rails_helper'

RSpec.describe DirectedRelationshipsController, type: :controller do
  render_views

  it 'should GET index' do
    get :index
    expect_collection_response total: 0
  end

  it 'should not GET show' do
    get :show, params: { id: DirectedRelationship.first.id }
    expect(response).to be_forbidden
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 8
    end
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 14
    end

    it 'should GET show' do
      get :show, params: { id: DirectedRelationship.first.id }
      expect(response).to be_success
      expect(json['relation_name']).to be_a(String)
      expect(json['relationship']).to be_nil
    end

    it 'should GET show' do
      get :show, params: {
        id: DirectedRelationship.first.id, include: 'relationship'
      }
      expect(response).to be_success
      expect(json['relation_name']).to be_a(String)
      expect(json['relationship']).to be_a(Hash)
    end

    it 'should GET index with pagination & filters' do
      louvre = Entity.find_by!(name: 'Louvre')
      mona_lisa = Entity.find_by!(name: 'Mona Lisa')
      works = Kind.find_by!(name: 'work')

      get :index, params: { per_page: 3 }
      expect_collection_response count: 3

      get :index, params: { per_page: 5, page: 3 }
      expect_collection_response count: 4

      get :index, params: { from_entity_id: louvre.id }
      expect_collection_response total: 2

      get :index, params: { relation_name: 'shows' }
      expect_collection_response total: 2

      get :index, params: { relation_name: 'is related to' }
      expect_collection_response total: 2

      get :index, params: {
        relation_name: 'is related to',
        from_entity_id: mona_lisa.id
      }
      expect_collection_response total: 1

      get :index, params: { from_kind_id: works.id }
      expect_collection_response total: 7

      get :index, params: { to_kind_id: Kind.medium_kind_id }
      expect_collection_response total: 2

      get :index, params: { except_to_kind_id: Kind.medium_kind_id }
      expect_collection_response total: 12

      get :index, params: { from_entity_id: "#{louvre.id},#{mona_lisa.id}" }
      expect_collection_response total: 6

      get :index, params: { to_entity_id: "#{louvre.id},#{mona_lisa.id}" }
      expect_collection_response total: 6

      get :index, params: { from_kind_id: "#{works.id},#{Kind.medium_kind_id}" }
      expect_collection_response total: 9

      get :index, params: { to_kind_id: "#{works.id},#{Kind.medium_kind_id}" }
      expect_collection_response total: 9

      get :index, params: {
        except_to_kind_id: "#{works.id},#{Kind.medium_kind_id}"
      }
      expect_collection_response total: 5

      get :index, params: { relation_name: "shows,is located in" }
      expect_collection_response total: 4
    end
  end
end

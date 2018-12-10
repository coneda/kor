require 'rails_helper'

RSpec.describe RelationsController, type: :controller do
  render_views

  it 'should GET index' do
    get 'index'
    expect_collection_response count: 6
  end

  it 'should GET names' do
    get 'names'
    expect(response).to be_success
    expect(json.size).to eq(7)
  end

  it 'should not GET show' do
    relation = Relation.find_by! name: 'has created'
    get 'show', id: relation.id
    expect(response).to be_success
    expect(json['name']).to eq('has created')
  end

  it 'should not POST create' do
    people = Kind.find_by! name: 'person'
    locations = Kind.find_by! name: 'location'
    params = {
      from_kind_id: people.id,
      name: 'born in',
      reverse_name: 'place of death',
      to_kind_id: locations.id
    }

    post 'create', relation: params
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    relation = Relation.find_by! name: 'has created'
    patch 'update', id: relation.id, relation: { reverse_name: 'was created by' }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    relation = Relation.find_by! name: 'has created'
    delete 'destroy', id: relation.id
    expect(response).to be_forbidden
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should not POST create' do
      people = Kind.find_by! name: 'person'
      locations = Kind.find_by! name: 'location'
      params = {
        from_kind_id: people.id,
        name: 'born in',
        reverse_name: 'place of death',
        to_kind_id: locations.id
      }

      post 'create', relation: params
      expect(response).to be_forbidden
    end

    it 'should not PATCH update' do
      relation = Relation.find_by! name: 'has created'
      patch 'update', id: relation.id, relation: { reverse_name: 'was created by' }
      expect(response).to be_forbidden
    end

    it 'should not DELETE destroy' do
      relation = Relation.find_by! name: 'has created'
      delete 'destroy', id: relation.id
      expect(response).to be_forbidden
    end
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      people = Kind.find_by! name: 'person'
      locations = Kind.find_by! name: 'location'
      params = {
        from_kind_id: people.id,
        name: 'born in',
        reverse_name: 'place of death',
        to_kind_id: locations.id
      }

      post 'create', relation: params
      expect_created_response
      relation = Relation.find(json['id'])
      expect(relation.from_kind_id).to eq(people.id)
      expect(relation.name).to eq('born in')
      expect(relation.reverse_name).to eq('place of death')
      expect(relation.to_kind_id).to eq(locations.id)
    end

    it 'should PATCH update' do
      relation = Relation.find_by! name: 'has created'
      patch 'update', id: relation.id, relation: { reverse_name: 'was created by' }
      expect_updated_response
      expect(relation.reload.reverse_name).to eq('was created by')
    end

    it 'should DELETE destroy' do
      relation = Relation.find_by! name: 'has created'
      delete 'destroy', id: relation.id
      expect_deleted_response
      expect(Relation.find_by(id: relation.id)).to be_nil
    end
  end
end

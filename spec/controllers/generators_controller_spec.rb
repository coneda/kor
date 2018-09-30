require 'rails_helper'

RSpec.describe GeneratorsController, type: :controller do
  render_views

  it 'should GET show' do
    generator = Generator.first
    get :show, id: generator.id, kind_id: generator.kind_id
    expect(response).to be_success
    expect(json['directive']).to be_a(String)
    expect(json['created_at']).to be_nil
  end

  it 'should GET show with additions' do
    generator = Generator.first
    get :show, id: generator.id, kind_id: generator.kind_id, include: 'technical'
    expect(response).to be_success
    expect(Time.parse json['created_at']).to be < Time.now
  end

  it 'should not POST create' do
    people = Kind.find_by! name: 'person'
    post :create, kind_id: people.id, generator: {
      name: 'viaf', directive: 'https://viaf.org/id/{{entity.dataset.viaf}}'
    }
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    generator = Generator.first
    post :update, kind_id: generator.kind_id, id: generator.id, generator: {
      directive: 'https://wendig.io/viaf/{{entity.dataset.viaf}}'
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    generator = Generator.first
    delete :destroy, kind_id: generator.kind_id, id: generator.id
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      people = Kind.find_by! name: 'person'
      post :create, kind_id: people.id, generator: {
        name: 'viaf', directive: 'https://viaf.org/id/{{entity.dataset.viaf}}'
      }
      expect_created_response
    end

    it 'should PATCH update' do
      generator = Generator.first
      post :update, kind_id: generator.kind_id, id: generator.id, generator: {
        directive: 'https://wendig.io/viaf/{{entity.dataset.viaf}}'
      }
      expect_updated_response
    end

    it 'should DELETE destroy' do
      generator = Generator.first
      delete :destroy, kind_id: generator.kind_id, id: generator.id
      expect_deleted_response
    end
  end
end
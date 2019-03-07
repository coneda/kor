require 'rails_helper'

RSpec.describe FieldsController, type: :controller do
  render_views

  it 'should GET show' do
    people = Kind.find_by! name: 'person'
    get :show, params: { id: Field.first.id, kind_id: people.id }
    expect(response).to be_success
    expect(json['name']).to be_a(String)
    expect(json['created_at']).to be_nil
  end

  it 'should GET types' do
    get :types
    expect(response).to be_success
    expect(json).to be_a(Array)
    expect(json[0]['name']).to eq('Fields::Select')
  end

  it 'should GET show with additions' do
    people = Kind.find_by! name: 'person'
    get :show, params: {
      id: Field.first.id, kind_id: people.id, include: 'technical'
    }
    expect(response).to be_success
    expect(json['name']).to be_a(String)
    expect(Time.parse json['created_at']).to be < Time.now
  end

  it 'should not POST create' do
    people = Kind.find_by! name: 'person'
    post :create, params: {
      kind_id: people.id, field: {
        type: 'Fields::String', name: 'isbn', show_label: 'ISBN'
      }
    }
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    people = Kind.find_by! name: 'person'
    field = people.fields.first
    post :update, params: {
      kind_id: people.id, id: field.id, field: {
        show_label: 'GND Identifier'
      }
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    people = Kind.find_by! name: 'person'
    field = people.fields.first
    delete :destroy, params: { kind_id: people.id, id: field.id }
    expect(response).to be_forbidden
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should POST create' do
      people = Kind.find_by! name: 'person'
      post :create, params: {
        kind_id: people.id, field: {
          type: 'Fields::String', name: 'isbn', show_label: 'ISBN'
        }
      }
      expect_created_response
    end

    it 'should sanitize the class string' do
      people = Kind.find_by! name: 'person'
      post :create, params: {
        kind_id: people.id,
        field: {
          type: 'Wrong::Klass', name: 'isbn', show_label: 'ISBN'
        }
      }
      expect_created_response
      expect(people.reload.fields.last.type).to eq('Fields::String')
    end

    it 'should PATCH update' do
      people = Kind.find_by! name: 'person'
      field = people.fields.first
      post :update, params: {
        kind_id: people.id,
        id: field.id, field: {
          show_label: 'GND Identifier',
          form_label: 'GND ID',
          search_label: 'GND Identifier',
          is_identifier: true,
          show_on_entity: false
        }
      }
      expect_updated_response
      field = people.reload.fields.first
      expect(field.form_label).to eq('GND ID')
      expect(field.search_label).to eq('GND Identifier')
      expect(field.is_identifier).to be_truthy
      expect(field.show_on_entity).to be_falsey
    end

    it 'should not allow to change the type when updating' do
      people = Kind.find_by! name: 'person'
      field = people.fields.first
      post :update, params: { 
        kind_id: people.id,
        id: field.id,
        field: {
          type: 'Fields::Regex',
          show_label: 'GND Identifier'
        }
      }
      expect(response).to be_client_error
      expect(json['errors']['type']).to include("can't be changed")
    end

    it 'should DELETE destroy' do
      people = Kind.find_by! name: 'person'
      field = people.fields.first
      delete :destroy, params: { kind_id: people.id, id: field.id }
      expect_deleted_response
    end
  end
end

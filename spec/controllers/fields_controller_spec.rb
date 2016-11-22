require 'rails_helper'

describe FieldsController, type: :controller do

  render_views

  def data
    JSON.parse(response.body)
  end

  before :each do
    request.headers['accept'] = 'application/json'
    @people = FactoryGirl.create :people
    @admin = FactoryGirl.create :admin
  end


  it 'allow read access to field types' do
    get :types, kind_id: @people.id
    expect(response.status).to eq(200)
    expect(data).to include({'name' => 'Fields::String', 'label' => 'String'})
  end

  it 'should allow read access to everybody' do
    get :index, kind_id: @people.id
    expect(response.status).to eq(200)
  end

  it 'should deny write access to non-kind-admins' do
    @guest = FactoryGirl.create :guest

    post :create, kind_id: @people.id
    expect(response.status).to eq(403)
  end

  context 'as admin' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
    end

    it 'should sanitize the class string' do
      post :create, kind_id: @people.id, klass: "Wrong::Class"
      expect(response.status).to eq(406)
      expect(data['record']['type']).to eq('Fields::String')
    end

    it 'should comply with response policy' do
      post :create, kind_id: @people.id, field: {
        name: 'gnd_id', show_label: 'GND-ID'
      }
      expect(response.status).to eq(200)
      expect(data['message']).to match(/^[^\s]+ has been created$/)
      id = data['record']['id']
      expect(id).to be_a(Integer)

      patch :update, kind_id: @people.id, id: id, field: {show_label: 'GND_ID'}
      expect(response.status).to eq(200)
      expect(data['message']).to match(/^[^\s]+ has been changed$/)
      expect(data['record']['id']).to be_a(Integer)

      get :index, kind_id: @people.id
      expect(response.status).to eq(200)
      expect(data['records'].size).to eq(1)
      expect(data['page']).to eq(1)
      expect(data['total']).to eq(1)
      expect(data['per_page']).to eq(1)

      delete :destroy, kind_id: @people.id, id: id
      expect(response.status).to eq(200)
      expect(data['message']).to match(/^[^\s]+ has been deleted$/)
      expect(data['record']['id']).to be_a(Integer)      
    end

    it 'should not allow to change the type when updating' do
      post :create, kind_id: @people.id, klass: 'Fields::String', field: {
        name: 'gnd_id', show_label: 'GND-ID'
      }
      expect(response.status).to eq(200)
      expect(data['record']['type']).to eq('Fields::String')

      patch :update, kind_id: @people.id, id: data['record']['id'], field: {
        type: 'Fields::Regex'
      }
      expect(response.status).to eq(406)
      expect(data['record']['errors']['type']).to eq(["can't be changed"])
    end

    it 'should allow to set attributes' do
      post :create, kind_id: @people.id, klass: 'Fields::String', field: {
        name: 'gnd_id', show_label: 'GND-ID',
        form_label: 'GND', search_label: 'GND',
        is_identifier: true, show_on_entity: false,
        abstract: true
      }
      expect(response.status).to eq(200)
      expect(data['record']['name']).to eq('gnd_id')
      expect(data['record']['show_label']).to eq('GND-ID')
      expect(data['record']['form_label']).to eq('GND')
      expect(data['record']['search_label']).to eq('GND')
      expect(data['record']['is_identifier']).to eq(true)
      expect(data['record']['show_on_entity']).to eq(false)
    end

  end

end
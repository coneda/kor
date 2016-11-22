require 'rails_helper'

describe GeneratorsController, type: :controller do

  render_views

  def data
    JSON.parse(response.body)
  end

  before :each do
    request.headers['accept'] = 'application/json'
    @people = FactoryGirl.create :people
    @admin = FactoryGirl.create :admin
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

    it 'should comply with response policy' do
      post :create, kind_id: @people.id, generator: {
        name: 'gnd_id', directive: '<span>something</span>'
      }
      expect(response.status).to eq(200)
      expect(data['message']).to match(/^[^\s]+ has been created$/)
      id = data['record']['id']
      expect(id).to be_a(Integer)

      patch :update, kind_id: @people.id, id: id, generator: {
        directive: '<span>something</span>'
      }
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

    it 'should allow to set attributes' do
      post :create, kind_id: @people.id, klass: 'generators::String', generator: {
        name: 'gnd_link', directive: '<span>something</span>'
      }
      expect(response.status).to eq(200)
      expect(data['record']['name']).to eq('gnd_link')
      expect(data['record']['directive']).to eq('<span>something</span>')
    end

  end

end
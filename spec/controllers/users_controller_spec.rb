require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  it 'should not GET index' do
    get :index
    expect(response).to be_forbidden
  end

  it 'should not GET show' do
    get :show, params: {id: User.guest.id}
    expect(response).to be_forbidden
  end

  it 'should not GET me' do
    get :me
    expect(response).to be_unauthorized
  end

  it 'should not POST create' do
    post :create, params: {user: {name: 'wendig', email: 'info@wendig.io'}}
    expect(response).to be_forbidden
  end

  it 'should not PATCH update' do
    patch :update, params: {
      id: User.admin.id, user: {email: 'info@wendig.io'}
    }
    expect(response).to be_forbidden
  end

  it 'should not DELETE destroy' do
    delete :destroy, params: {id: User.admin.id}
    expect(response).to be_forbidden
  end

  it 'should not PATCH reset_password' do
    user = User.find_by! name: 'jdoe'
    patch :reset_password, params: {id: user.id}
    expect(response).to be_forbidden
  end

  it 'should not PATCH reset_login_attempts' do
    user = User.find_by! name: 'jdoe'
    patch :reset_login_attempts, params: {id: user.id}
    expect(response).to be_forbidden
  end

  it 'should not PATCH accept_terms' do
    patch :accept_terms
    expect(response).to be_client_error
  end

  context 'as jdoe' do
    before :each do
      current_user User.find_by!(name: 'jdoe')
    end

    it 'should not GET index' do
      get :index
      expect(response).to be_forbidden
    end

    it 'should GET me' do
      get :me
      expect(response).to be_success
      expect(json['name']).to eq('jdoe')
    end

    it 'should PATCH update_me (but not change permissions)' do
      patch :update_me, params: {user: {locale: 'de', admin: true}}
      expect_updated_response
      user = User.find_by!(name: 'jdoe')
      expect(user.locale).to eq('de')
      expect(user.admin).to be_falsey
    end

    it 'should not GET show' do
      user = User.find_by! name: 'jdoe'
      get :show, params: {id: user.id}
      expect(response).to be_forbidden
    end

    it 'should not PATCH reset_password' do
      user = User.find_by! name: 'jdoe'
      patch :reset_password, params: {id: user.id}
      expect(response).to be_forbidden
    end

    it 'should not PATCH reset_login_attempts' do
      user = User.find_by! name: 'jdoe'
      patch :reset_login_attempts, params: {id: user.id}
      expect(response).to be_forbidden
    end

    it 'should PATCH accept_terms' do
      patch :accept_terms
      expect(response).to be_success
    end
  end

  context 'as admin' do
    before :each do
      current_user User.admin
    end

    it 'should GET index' do
      get :index
      expect_collection_response total: 5
    end

    it 'should GET show' do
      user = User.find_by! name: 'jdoe'
      get :show, params: {id: user.id}
      expect(response).to be_success
      expect(json['name']).to eq('jdoe')
      expect(json['permissions']).to be_nil
    end

    it 'should GET show with additions' do
      user = User.find_by! name: 'jdoe'
      get :show, params: {id: user.id, include: 'permissions'}
      expect(response).to be_success
      expect(json['name']).to eq('jdoe')
      expect(json['permissions']).to be_a(Hash)
    end

    it 'should POST create' do
      post :create, params: {
        user: {name: 'wendig', email: 'info@wendig.io'}
      }
      expect_created_response
      User.find_by!(name: 'wendig')
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

    it 'should POST create (with notification)' do
      post :create, params: {
        user: {name: 'wendig', email: 'info@wendig.io'},
        notify: true
      }
      expect_created_response
      User.find_by!(name: 'wendig')
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'should PATCH update' do
      user = User.find_by! name: 'jdoe'
      patch :update, params: {
        id: user.id, user: {name: 'john', admin: true}
      }
      expect_updated_response
      expect(user.reload.name).to eq('john')
      expect(user.reload.admin).to be_truthy
    end

    it 'should DELETE destroy' do
      user = User.find_by! name: 'jdoe'
      delete :destroy, params: {id: user.id}
      expect_deleted_response
      expect(User.find_by(id: user.id)).to be_nil
    end

    it 'should PATCH reset_password' do
      user = User.find_by! name: 'jdoe'
      pwd = user.password
      patch :reset_password, params: {id: user.id}
      expect(response).to be_success
      expect(user.reload.password).not_to eq(pwd)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'should PATCH reset_login_attempts' do
      user = User.find_by! name: 'jdoe'
      user.add_login_attempt
      user.save
      patch :reset_login_attempts, params: {id: user.id}
      expect(response).to be_success
      expect(user.reload.login_attempts).to be_empty
    end
  end

  # old

  # it "should render a json formatted list of users for autocomplete inputs" do
  #   FactoryBot.create :hmustermann
  #   FactoryBot.create :jdoe

  #   allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.admin)
  #   allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(false)
  #   request.env["HTTP_ACCEPT"] = "application/json"

  #   get :index
  #   expect(response.status).to eq(200)
  #   expect(JSON.parse(response.body).size).to eq(3)

  #   get :index, :search_string => "doe"
  #   expect(JSON.parse(response.body).size).to eq(1)

  #   get :index, :search_string => "usterm"
  #   expect(JSON.parse(response.body).size).to eq(1)

  #   get :index, :search_string => "doesntexist"
  #   expect(JSON.parse(response.body).size).to eq(0)
  # end
end

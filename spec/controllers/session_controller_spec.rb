require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  render_views
  
  it "should logout in any case and display a message" do
    current_user User.admin
    post :destroy
    expect(response).to be_success
    expect(json['message']).to match(/logged out/)
  end
  
  it "should deny access if there were too many login attempts in one hour" do
    request.headers['HTTP_REFERER'] = 'http://test.host/login'
    
    for i in 1..3 do
      post :create, :username => 'admin', :password => 'wrong'
      expect(response).to be_client_error
      expect(json['message']).to match(/username or password could not be found/)
    end
  
    post :create, :username => 'admin', :password => 'wrong'
    expect(response).to be_client_error
    expect(json['message']).to match(/too many login attempts/)
    
    # one hour later
    later = Time.now + 1.hour
    allow(Time).to receive(:now).and_return(later)
    post :create, :username => 'admin', :password => 'wrong'
    expect(response).to be_client_error
    expect(json['message']).to match(/username or password could not be found/)
  end
  
  it "should reset the users login attempts when he authenticated successfully" do
    User.admin.update login_attempts: [Time.now, Time.now]
    post :create, username: 'admin', password: 'admin'
    expect(response).to be_success
    expect(User.admin.login_attempts).to be_empty
  end
  
  it "should not crash when supplying a non existing username" do
    request.headers['HTTP_REFERER'] = 'http://test.host/login'
    post :create, username: "does_not_exist", password: 'wrong'
    expect(response).to be_client_error
    expect(json['message']).to match(/username or password could not be found/)
  end

  it "should fix cryptography to use sha2" do
    User.admin.update_column(:password, User.legacy_crypt('admin'))
    expect(User.admin.password.size).to eq(40)

    post :create, username: 'admin', password: 'admin'
    expect(response).to be_success
    expect(User.admin.password.size).to eq(64)
  end

  it 'should drop the session on expiry'

  # TODO: move this to auth_spec.rb
  context 'with environment variables' do
    it 'should login users via environment variables' do
      user = User.find_by! name: 'jdoe'
      request.env['mail'] = 'jdoe@example.com'
      request.env['HTTP_REMOTE_USER'] = 'jdoe'

      get :env_auth
      expect(response).to redirect_to('/')
      expect(session[:user_id]).not_to eq(user.id)

      request.env['REMOTE_USER'] = 'jdoe'

      get :env_auth
      expect(response).to redirect_to('/')
      expect(session[:user_id]).to eq(user.id)
    end

    it 'should create users authenticated via environment variables' do
      request.env['mail'] = 'jdoe@example.com'
      request.env['REMOTE_USER'] = 'mrossi'

      get :env_auth

      user = User.find_by!(name: 'mrossi')
      expect(session[:user_id]).to eq(user.id)
    end

    it 'should override the users email address' do
      request.env['REMOTE_USER'] = 'jdoe'
      request.env['mail'] = 'jdoe@example.com'

      get :env_auth
      
      user = User.find_by!(name: 'jdoe')
      expect(user.email).to eq('jdoe@example.com')
    end

    it 'should use a splitter if given' do
      request.env['REMOTE_USER'] = 'jdoe;John Doe'
      request.env['mail'] = 'jdoe@example.com;john.doe@example.com'

      get :env_auth

      user = User.find_by!(name: 'jdoe')
      expect(session[:user_id]).to eq(user.id)
      expect(user.email).to eq('jdoe@example.com')
    end

    it "should respect a display name if given and configured" do
      request.env['REMOTE_USER'] = 'jdoe'
      request.env['mail'] = 'jdoe@example.com'
      request.env['full_name'] = 'John Carl Doe'

      get :env_auth

      user = User.find_by!(name: 'jdoe')
      expect(session[:user_id]).to eq(user.id)
      expect(user.full_name).to eq('John Carl Doe')
    end

    it "should allow authentication success despite faulty user data" do
      user = User.find_by!(name: 'jdoe')
      User.find_by!(name: 'ldap').destroy
      request.env['REMOTE_USER'] = 'jdoe'
      request.env['mail'] = 'jdoe@example.com'

      # should provoke error on update: map_to user doesn't exist
      get :env_auth
      expect(session[:user_id]).not_to eq(user.id)

      ENV['AUTH_FAIL_ON_UPDATE_ERRORS'] = 'false'
      get :env_auth
      expect(session[:user_id]).to eq(user.id)
      expect(user.reload.full_name).to eq('John Doe')
    end

    it 'should not POST recovery (wrong email)' do
      post :recovery, email: 'info@does.not.exist'
      expect(response).to be_not_found
    end

    it 'should POST recovery (correct email)' do
      old = jdoe.password
      post :recovery, email: jdoe.email
      expect(response).to be_success
      expect(jdoe.reload.password).not_to eq(old)
    end
  end
end

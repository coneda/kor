require 'rails_helper'

RSpec.describe AuthenticationController, :type => :controller do
  include DataHelper
  
  before :each do 
    test_data_for_auth
  end
  
  it "should logout in any case and display a message" do
    session[:user_id] = User.find_by_name('admin').id
    post :logout
    expect(response).to redirect_to(root_url)
    expect(flash[:notice]).to eql "you have been logged out successfully"
  end
  
  it "should deny access if there were too many login attempts in one hour" do
    for i in 1..3 do
      post :login, :username => 'admin', :password => 'wrong'
      expect(response).to redirect_to(:action => 'form')
      expect(flash[:error]).to eql("username or password could not be found")
    end
  
    post :login, :username => 'admin', :password => 'wrong'
    expect(response).to redirect_to(:action => 'form')
    expect(flash[:error]).to match("many login attempts")
    
    # one hour later
    later = Time.now + 1.hour
    allow(Time).to receive(:now).and_return(later)
    post :login, :username => 'admin', :password => 'wrong'
    expect(response).to redirect_to(:action => 'form')
    expect(flash[:error]).to match("username or password could not be found")
  end
  
  it "should reset the users login attempts when he authenticated successfully" do
    User.find_by_name('admin').update_attributes(:login_attempts => [ Time.now, Time.now ])
    post :login, :username => 'admin', :password => 'admin'
    expect(User.find_by_name('admin').login_attempts).to be_empty
  end
  
  it "should not crash when supplying a non existing username" do
    post :login, :username => "does_not_exist", :password => 'wrong'
    expect(response).to redirect_to(:action => 'form')
  end

  it "should fix cryptography to use sha2" do
    User.admin.update_column(:password, User.legacy_crypt('admin'))
    expect(User.admin.password.size).to eq(40)

    post :login, username: 'admin', password: 'admin'
    expect(User.admin.password.size).to eq(64)
  end

  # TODO: move this to auth_spec.rb
  context 'with environment variables' do

    it 'should login users via environment variables' do
      jdoe = FactoryGirl.create :jdoe
      FactoryGirl.create :ldap_template
      request.env['mail'] = 'jdoe@example.com'
      request.env['HTTP_REMOTE_USER'] = 'jdoe'

      get :form
      expect(response.status).to eq(200)

      request.env['REMOTE_USER'] = 'jdoe'

      get :form
      expect(response.status).to eq(302)

      expect(session[:user_id]).to eq(jdoe.id)
    end

    it 'should create users authenticated via environment variables' do
      FactoryGirl.create :ldap_template
      request.env['mail'] = 'jdoe@example.com'
      request.env['REMOTE_USER'] = 'jdoe'

      get :form
      expect(response.status).to eq(302)

      jdoe = User.where(name: 'jdoe').first
      expect(session[:user_id]).to eq(jdoe.id)
    end

    it 'should override the users email address' do
      FactoryGirl.create :ldap_template
      request.env['REMOTE_USER'] = 'jdoe'
      request.env['mail'] = 'jdoe@example.com'

      get :form
      expect(response.status).to eq(302)
    end

    it 'should use a splitter if given' do
      FactoryGirl.create :ldap_template
      request.env['REMOTE_USER'] = 'jdoe;John Doe'
      request.env['mail'] = 'jdoe@example.com;john.doe@example.com'

      get :form
      expect(response.status).to eq(302)
    end

    it "should respect a display name if given and configured" do
      FactoryGirl.create :ldap_template
      request.env['REMOTE_USER'] = 'jdoe'
      request.env['mail'] = 'jdoe@example.com'
      request.env['full_name'] = 'John Carl Doe'

      get :form
      expect(response.status).to eq(302)

      expect(User.where(name: 'jdoe').first.full_name).to eq('John Carl Doe')
    end

  end


end

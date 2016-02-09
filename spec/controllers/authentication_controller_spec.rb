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
end

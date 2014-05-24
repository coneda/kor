require 'spec_helper'

describe AuthenticationController do
  include DataHelper
  
  before :each do 
    test_data_for_auth
  end
  
  it "should logout in any case and display a message" do
    session[:user_id] = User.find_by_name('admin').id
    post :logout
    response.should redirect_to(root_url)
    flash[:notice].should eql "Sie haben sich erfolgreich abgemeldet"
  end
  
  it "should deny access if there were too many login attempts in one hour" do
    for i in 1..3 do
      post :login, :username => 'admin', :password => 'wrong'
      response.should redirect_to(:action => 'form')
      flash[:error].should eql("der Benutzername oder das Passwort waren falsch")
    end
  
    post :login, :username => 'admin', :password => 'wrong'
    response.should redirect_to(:action => 'form')
    flash[:error].should match("Anmeldeversuche")
    
    # one hour later
    later = Time.now + 1.hour
    Time.stub(:now).and_return(later)
    post :login, :username => 'admin', :password => 'wrong'
    response.should redirect_to(:action => 'form')
    flash[:error].should match("der Benutzername oder das Passwort waren falsch")
  end
  
  it "should reset the users login attempts when he authenticated successfully" do
    User.find_by_name('admin').update_attributes(:login_attempts => [ Time.now, Time.now ])
    post :login, :username => 'admin', :password => 'admin'
    User.find_by_name('admin').login_attempts.should be_empty
  end
  
  it "should not crash when supplying a non existing username" do
    post :login, :username => "does_not_exist", :password => 'wrong'
    response.should redirect_to(:action => 'form')
  end
end

require 'spec_helper'

describe UsersController do
  include DataHelper
  include AuthHelper
  
  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should allow non user admins to change their profile" do
    john = User.make
    session[:user_id] = john.id
  
    put :update_self, :user => {:home_page => '/entities/gallery'}
    
    response.should_not redirect_to(denied_path)
  end
  
  it "should only grant access to the user admin to authorized users" do
    fake_authentication :user => User.make_unsaved(:name => 'gloria', :user_admin => false)
    get :index
    response.should redirect_to('/login')
  end
  
end

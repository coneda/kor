require 'spec_helper'

describe UserGroupsController do
  include DataHelper
  
  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should show GET '/user_groups/1'" do
    UserGroup.stub(:find).and_return(UserGroup.make_unsaved(:name => 'TestGroup'))
    
    get :show, :id => 1
    response.should be_success
  end
  
end
  

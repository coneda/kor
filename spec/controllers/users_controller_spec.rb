require 'spec_helper'

describe UsersController do
  render_views

  include DataHelper
  include AuthHelper
  
  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should allow non user admins to change their profile" do
    john = FactoryGirl.create :jdoe
    session[:user_id] = john.id
  
    put :update_self, :user => {:home_page => '/entities/gallery'}
    
    response.should_not redirect_to(denied_path)
  end
  
  it "should only grant access to the user admin to authorized users" do
    fake_authentication :user => User.make_unsaved(:name => 'gloria', :user_admin => false)
    get :index
    response.should redirect_to('/login')
  end

  it "should render a json formatted list of users for autocomplete inputs" do
    FactoryGirl.create :hmustermann
    FactoryGirl.create :jdoe

    # fake_authentication :user => User.admin
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.admin)
    allow_any_instance_of(ApplicationController).to receive(:session_expired?).and_return(false)
    request.env["HTTP_ACCEPT"] = "application/json"

    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse response.body).to have(2).items

    get :index, :search_string => "doe"
    expect(JSON.parse response.body).to have(1).items

    get :index, :search_string => "usterm"
    expect(JSON.parse response.body).to have(1).items

    get :index, :search_string => "doesntexist"
    expect(JSON.parse response.body).to have(0).items
  end
  
end

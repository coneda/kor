require 'rails_helper'

RSpec.describe RelationsController, :type => :controller do
  render_views

  include DataHelper

  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should save kind ids" do
    @is_equivalent_to = Relation.find_by_name('is equivalent to')

    put :update, :id => @is_equivalent_to.id, :relation => {
      :from_kind_ids => [ @person_kind.id, @artwork_kind.id ]
    }
    
    expect(@is_equivalent_to.reload.from_kind_ids).to eql([ @person_kind.id, @artwork_kind.id ])
  end

  it "should allow a json list without auth" do
    session[:user_id] = nil

    get :names, :format => "json"
    
    expect(response.status).to eq(200)
  end
  
end

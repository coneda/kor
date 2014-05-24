require 'spec_helper'

describe RelationsController do
  render_views

  include DataHelper

  before :each do
    test_data
  
    session[:user_id] = User.admin.id
    session[:expires_at] = Kor.session_expiry_time
  end
  
  it "should save kind ids" do
    put :update, :id => @is_equivalent_to.id, :relation => {
      :from_kind_ids => [ @person_kind.id, @artwork_kind.id ]
    }
    
    @is_equivalent_to.reload.from_kind_ids.should eql([ @person_kind.id, @artwork_kind.id ])
  end
  
end

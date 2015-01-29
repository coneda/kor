require 'spec_helper'

describe ComponentSearchController do

  it "should pass through the per_page parameter" do
    FactoryGirl.create :guest

    expect_any_instance_of(Kor::Elastic).to receive(:search).with(
      hash_including(:per_page => 433)
    ).and_call_original

    get :component_search, :per_page => 433, :format => "json"
  end

end
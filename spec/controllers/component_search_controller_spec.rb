require 'rails_helper'

describe ComponentSearchController, type: :controller do

  it "should pass through the per_page parameter" do
    FactoryGirl.create :guest

    expect_any_instance_of(Kor::Elastic).to receive(:search).with(
      hash_including(:per_page => 433)
    ).and_call_original

    get :component_search, :per_page => 433, :format => "json"
  end

  it "should allow an array for kind_ids" do
    guest = FactoryGirl.create :guest

    expect_any_instance_of(Kor::Elastic).to receive(:search).twice.with(
      hash_including(:kind_id => [1,2])
    ).and_call_original

    get :component_search, format: 'json', kind_id: [1,2]
    get :component_search, format: 'json', kind_id: "1,2"
  end

end
require 'spec_helper'

require "xmlsimple"

describe Api::Dispacher do
  it "should return error xml if the action was not found" do
    response = Api::Dispacher.request(
      :api_section => :kor, 
      :api_action => :does_not_exist
    )
    response.data.should be_nil
    response.status.should eql(400)
  end
  
  it "should return error xml if the section was not found" do
    response = Api::Dispacher.request(:api_section => :does_not_exist)
    response.data.should be_nil
    response.status.should eql(400)
  end
  
end

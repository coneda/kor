require 'spec_helper'

require "xmlsimple"

describe Api::Response do
  it "should have error status when data was nil" do
    Api::Response.new(nil, :status => 404).status.should eql(404)
  end
  
  it "should return xml when nothing else was specified" do
    response = Api::Response.new(:type => 'bird', :color => 'blue')
    response.data.should eql(:type => 'bird', :color => 'blue')
  end
  
  it "should return the given data directly if the content type is not text/xml" do
    response = Api::Response.new("This is a test body", :content_type => 'text/plain')
    response.data.should eql("This is a test body")
  end
  
end

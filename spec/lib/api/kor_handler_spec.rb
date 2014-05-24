require 'spec_helper'

require "xmlsimple"

describe Api::Handlers::KorHandler do
  include DataHelper
  
  before :each do
    test_data
  end

  def handler
    @handler ||= Api::Handlers::KorHandler.new
  end
  
  def leonardo
    @leonardo ||= Kind.find_by_name('Person').entities.make(:name => 'Leonardo')
  end
  
  it "should return results for more than one identifier" do
    Entity.should_receive(:find_all_by_uuid_keep_order).and_return([@mona_lisa, leonardo])
    response = handler.handle('entity')
    response.data.should eql([@mona_lisa, leonardo])
  end

  it "should return the requested entity information as API::Response" do
    Entity.should_receive(:find_all_by_uuid_keep_order).and_return([@mona_lisa])
    response = handler.handle('entity')
    response.data.should eql([@mona_lisa])
  end
  
  it "should render the dataset" do
    Entity.should_receive(:find_all_by_uuid_keep_order).and_return([@mona_lisa])
    response = handler.handle('entity', :magnitude => 'extended')
    response.render.should match(/dataset/)
  end
end

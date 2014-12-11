require 'spec_helper'

describe ExceptionLog do
  
  it "should show all but render errors when asked to do so" do
    FactoryGirl.create :exception_log, :kind => 'ActionController::RoutingError'
    FactoryGirl.create :exception_log, :kind => 'NameError'
    expect(ExceptionLog.no_routing_errors.count).to eql(1)
  end
  
end

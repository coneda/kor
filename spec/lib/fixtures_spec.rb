require 'rails_helper'

describe "Fixtures" do
  
  include DataHelper
  
  before :each do
    test_data
  end
  
  it "should create authentication data" do
    expect(User.admin).not_to be_nil
    expect(User.authenticate("admin", "admin")).not_to be_nil
  end
  
  it "should create test images" do
    Delayed::Worker.delay_jobs = false

    e = FactoryGirl.create :picture_a
    
    expect(e.medium).not_to be_nil
    expect(e.medium.image.file?).to be_truthy
  end
end

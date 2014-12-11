require 'spec_helper'

describe "Machinist" do
  include DataHelper
  
  before :each do
    test_data
  end
  
  def work_off(jobs = 10)
    Delayed::Worker.new.work_off(jobs)
    if Delayed::Job.count > 0
      raise "Not all jobs have been processed, please check!"
    end
  end
  
  it "should create authentication data" do
    expect(User.admin).not_to be_nil
    expect(User.authenticate("admin", "admin")).not_to be_nil
  end
  
  it "should create test images" do
    e = FactoryGirl.create :image_a
    work_off
    
    expect(e.medium).not_to be_nil
    expect(e.medium.image.file?).to be_truthy
  end
end

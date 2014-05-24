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
    User.admin.should_not be_nil
    User.authenticate("admin", "admin").should_not be_nil
  end
  
  it "should create test images" do
    e = Entity.make(:medium, :medium => Medium.make_unsaved)
    work_off
    
    e.medium.should_not be_nil
    e.medium.image.file?.should be_true
  end
end

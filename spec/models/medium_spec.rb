# encoding: utf-8

require 'spec_helper'

describe Medium do

  def work_off(num = 10)
    Delayed::Worker.new.work_off num
    if Delayed::Job.count > 0
      debugger
      raise "Not all jobs have been processed, please check!"
    end
  end

  it "should not accept non-image-files as image attachment" do
    Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/text_file.txt")).valid?.should be_false
  end
  
  it "should accept images as image attachment" do
    Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/image_a.jpg")).valid?.should be_true
  end
  
  it "should return correct paths and urls" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    
    work_off
    medium.reload

    medium.path(:original).should eql("#{Rails.root}/data/media.test/original/#{medium.ids}/document.txt")
    medium.path(:icon).should eql("#{Rails.root}/public/content_types/text/plain.gif")
    medium.url(:original).should eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    medium.url(:icon).should eql('/content_types/text/plain.gif')
    
    medium.update_attributes(:image => File.open("#{Rails.root}/spec/fixtures/image_a.jpg"))
    work_off
    medium.reload
    
    medium.path(:original).should eql("#{Rails.root}/data/media.test/original/#{medium.ids}/document.txt")
    medium.path(:icon).should eql("#{Rails.root}/data/media.test/icon/#{medium.ids}/image.jpg")
    medium.url(:original).should eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    medium.url(:icon).should eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    
    medium.update_attributes(:document => nil)
    work_off
    medium.reload
    
    medium.path(:original).should eql("#{Rails.root}/data/media.test/original/#{medium.ids}/image.jpg")
    medium.path(:icon).should eql("#{Rails.root}/data/media.test/icon/#{medium.ids}/image.jpg")
    medium.url(:original).should eql("/media/images/original/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    medium.url(:icon).should eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
  end
  
  it "should read an escaped file uri to an existing file" do
    medium = Medium.create :uri => "file:///#{Rails.root}/spec/fixtures/image_a.jpg"
    work_off
    medium = Medium.last
    
    medium.document.file?.should be_false
    medium.image.to_file.should_not be_nil
    medium.image.content_type.should eql('image/jpeg')
  end
  
  it "should not store the same file twice (hashing-check)" do
    Medium.create :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    medium = Medium.new :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    
    medium.save.should be_false
    medium.errors.full_messages.should eql(['Prüfsumme eine inhaltlich gleiche Datei wurde bereits hochgeladen'])
  end
  
  it "should return the dummy when no files are attached" do
    medium = Medium.new
    medium.save.should be_false
    medium.errors[:document].should == ['eine Datei muss ausgewählt werden']
  end
  
  it "should delete all files after destruction of an image" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
    work_off
    medium = Medium.last
    
    paths = [:original, :icon, :thumbnail, :preview, :normal].map{|s| medium.path(s)}
    
    paths.each do |path|
      File.exists?(path).should be_true
    end
    
    medium.destroy
    
    paths.each do |path|
      File.exists?(path).should be_false
    end
  end
  
  it "should delete all files after destruction of a non flash video" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/video_a.m4v")
    work_off
    medium = Medium.last
    
    paths = [:original, :icon, :thumbnail, :preview, :normal].map{|s| medium.path(s)}
    paths << medium.custom_style_path(:flash)

    paths.each do |path|
      File.exists?(path).should be_true, "#{path} does not exist, but it should"
    end
    
    medium.destroy
    
    paths.each do |path|
      File.exists?(path).should be_false
    end
  end
  
  it "should not generate the checksum error twice" do
    original = Factory.create(:medium)
    duplicate = Factory.build(:medium)
    
    duplicate.valid?.should_not be_true
    duplicate.errors.full_messages.should == ["Prüfsumme eine inhaltlich gleiche Datei wurde bereits hochgeladen"]
  end
  
  it "should generate a delayed job for processing" do
    Delayed::Worker.delay_jobs = true
    Delayed::Job.count.should == 0
    medium = Factory.create(:medium)
    Delayed::Job.count.should == 1
  end
  
end

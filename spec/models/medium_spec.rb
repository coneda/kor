# encoding: utf-8

require 'rails_helper'

describe Medium do

  def work_off(num = 10)
    Delayed::Worker.new.work_off num
    if Delayed::Job.count > 0
      binding.pry
      raise "Not all jobs have been processed, please check!"
    end
  end

  it "should not accept non-image-files as image attachment" do
    expect(Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/text_file.txt")).valid?).to be_falsey
  end
  
  it "should accept images as image attachment" do
    medium = Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/image_a.jpg"))
    expect(medium).to be_valid
  end
  
  it "should return correct paths and urls" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    work_off
    medium.reload

    expect(medium.path(:original)).to eql("#{Rails.root}/data/media.test/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{Rails.root}/public/content_types/text/plain.gif")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql('/content_types/text/plain.gif')
    
    medium.update_attributes(:image => File.open("#{Rails.root}/spec/fixtures/image_a.jpg"))
    work_off
    medium.reload
    
    expect(medium.path(:original)).to eql("#{Rails.root}/data/media.test/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{Rails.root}/data/media.test/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    
    medium.update_attributes(:document => nil)
    work_off
    medium.reload
    
    expect(medium.path(:original)).to eql("#{Rails.root}/data/media.test/original/#{medium.ids}/image.jpg")
    expect(medium.path(:icon)).to eql("#{Rails.root}/data/media.test/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
  end
  
  it "should read an escaped file uri to an existing file" do
    medium = Medium.create :uri => "file:///#{Rails.root}/spec/fixtures/image_a.jpg"
    work_off
    medium = Medium.last
    
    expect(medium.document.file?).to be_falsey
    expect(medium.to_file :image).not_to be_nil
    expect(medium.image.content_type).to eql('image/jpeg')
  end
  
  it "should not store the same file twice (hashing-check)" do
    Medium.create :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    medium = Medium.new :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    
    expect(medium.save).to be_falsey
    expect(medium.errors.full_messages).to eql(['Prüfsumme eine inhaltlich gleiche Datei wurde bereits hochgeladen'])
  end
  
  it "should return the dummy when no files are attached" do
    medium = Medium.new
    expect(medium.save).to be_falsey
    expect(medium.errors[:document]).to eq(['eine Datei muss ausgewählt werden'])
  end
  
  it "should delete all files after destruction of an image" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
    work_off
    medium = Medium.last
    
    paths = [:original, :icon, :thumbnail, :preview, :normal].map{|s| medium.path(s)}
    
    paths.each do |path|
      expect(File.exists?(path)).to be_truthy
    end
    
    medium.destroy
    
    paths.each do |path|
      expect(File.exists?(path)).to be_falsey
    end
  end
  
  it "should delete all files after destruction of a non flash video" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/video_a.m4v")
    work_off
    medium = Medium.last
    
    paths = [:original, :icon, :thumbnail, :preview, :normal].map{|s| medium.path(s)}
    paths << medium.custom_style_path(:flash)

    paths.each do |path|
      expect(File.exists?(path)).to be_truthy, "#{path} does not exist, but it should"
    end
    
    medium.destroy
    
    paths.each do |path|
      expect(File.exists?(path)).to be_falsey
    end
  end
  
  it "should not generate the checksum error twice" do
    original = Factory.create(:medium)
    duplicate = Factory.build(:medium)
    
    expect(duplicate.valid?).not_to be_truthy
    expect(duplicate.errors.full_messages).to eq(["Prüfsumme eine inhaltlich gleiche Datei wurde bereits hochgeladen"])
  end
  
  it "should generate a delayed job for processing" do
    Delayed::Worker.delay_jobs = true
    expect(Delayed::Job.count).to eq(0)
    medium = Factory.create(:medium)
    expect(Delayed::Job.count).to eq(2)
  end

  it "should generate a datahash for attachments" do
    medium = FactoryGirl.create :medium
    medium = Medium.last
    expect(medium.datahash).to eq("233fcdfee7c55b3978967aacaefb9a08057607a0")
  end
  
end

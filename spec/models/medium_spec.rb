require 'rails_helper'

RSpec.describe Medium do
  it "should not accept non-image-files as image attachment" do
    expect(Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/text_file.txt")).valid?).to be_falsey
  end

  it "should accept images as image attachment" do
    medium = Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/image_c.jpg"))
    expect(medium).to be_valid
  end

  it "should return correct paths and urls" do
    medium = Medium.create document: File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{Rails.root}/public/content_types/text.gif")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql('/content_types/text.gif')

    medium.update_attributes(:image => File.open("#{Rails.root}/spec/fixtures/image_c.jpg"))
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{ENV['DATA_DIR']}/media/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")

    medium.update_attributes(:document => nil)
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/image.jpg")
    expect(medium.path(:icon)).to eql("#{ENV['DATA_DIR']}/media/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
  end

  it "should read an escaped file uri to an existing file" do
    Medium.create :uri => "file:///#{Rails.root}/spec/fixtures/image_c.jpg"
    medium = Medium.last

    expect(medium.document.file?).to be_falsey
    expect(medium.to_file :image).not_to be_nil
    expect(medium.image.content_type).to eql('image/jpeg')
  end

  it "should not store the same file twice (hashing-check)" do
    Medium.create :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")
    medium = Medium.new :document => File.open("#{Rails.root}/spec/fixtures/text_file.txt")

    expect(medium.save).to be_falsey
    expect(medium.errors.full_messages).to eql(
      ['checksum a file with identical content already exists']
    )
  end

  it "should return the dummy when no files are attached" do
    medium = Medium.new
    expect(medium.save).to be_falsey
    expect(medium.errors[:document]).to eq(
      [:file_must_be_set]
    )
  end

  it "should delete all files after destruction of an image" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/image_c.jpg")
    medium = Medium.last

    paths = [:original, :icon, :thumbnail, :preview, :normal].map do |s|
      medium.path(s)
    end

    paths.each do |path|
      expect(File.exist?(path)).to be_truthy
    end

    medium.destroy

    paths.each do |path|
      expect(File.exist?(path)).to be_falsey
    end
  end

  it "should not generate the checksum error twice" do
    FactoryBot.create(:medium_image_c)
    duplicate = FactoryBot.build(:medium_image_c)

    expect(duplicate.valid?).not_to be_truthy
    expect(duplicate.errors.full_messages).to eq(
      ["checksum a file with identical content already exists"]
    )
  end

  it "should generate a datahash for attachments" do
    FactoryBot.create :medium_image_c
    medium = Medium.last
    expect(medium.datahash).to eq("faf7e17cdeb3d4ce08bcb60e4d6dea8f6aa9eb73")
  end

  context 'content types' do
    it "should determine the type based on content type" do
      medium = Medium.new
      expect(medium.image?).to be_falsey
      expect(medium.video?).to be_falsey
      expect(medium.audio?).to be_falsey

      medium = FactoryBot.build(:picture_c).medium
      expect(medium.image?).to be_truthy

      medium = FactoryBot.build(:video_a).medium
      expect(medium.video?).to be_truthy

      medium = FactoryBot.build(:video_b).medium
      expect(medium.video?).to be_truthy

      medium = FactoryBot.build(:audio_a).medium
      expect(medium.audio?).to be_truthy

      medium = FactoryBot.build(:audio_b).medium
      expect(medium.audio?).to be_truthy
    end

    it "should not run the video processor for images" do
      entity = FactoryBot.build :picture_c
      expect(entity.medium.document).to receive(:im).at_least(:once)
      expect(entity.medium.document).not_to receive(:ogg_video)
      entity.save
    end

    it "should run the video processor for videos" do
      entity = FactoryBot.build :video_a
      expect(entity.medium.document).not_to receive(:im)
      expect(entity.medium.document).to receive(:ogg_video).at_least(:once)
      entity.save
    end

    it "should run the audio processor for audio" do
      entity = FactoryBot.build :audio_a
      expect(entity.medium.document).not_to receive(:im)
      expect(entity.medium.document).to receive(:ogg_audio).at_least(:once)
      entity.save
    end

    it "should convert a video to all 3 major html5 containers/codecs" do
      entity = FactoryBot.create :video_a
      document = entity.medium.document
      expect(File.size document.variant_path('mp4')).to be > 0
      expect(File.size document.variant_path('webm')).to be > 0
      expect(File.size document.variant_path('ogg.video')).to be > 0
    end

    it "should convert a audio file to all 2 major html5 containers/formats" do
      entity = FactoryBot.create :audio_a
      document = entity.medium.document
      expect(File.size document.variant_path('mp3')).to be > 0
      expect(File.size document.variant_path('ogg.audio')).to be > 0
    end

    it "should destroy custom styles with the medium" do
      entity = FactoryBot.create :audio_a
      document = entity.medium.document
      paths = [document.variant_path('mp3'), document.variant_path('ogg.audio')]

      entity.reload.destroy
      expect(File.exist? paths[0]).to be_falsey
      expect(File.exist? paths[1]).to be_falsey
    end
  end
end

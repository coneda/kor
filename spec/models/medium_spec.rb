require 'rails_helper'

RSpec.describe Medium do
  it "should not accept non-image-files as image attachment" do
    expect(Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/files/text_file.txt")).valid?).to be_falsey
  end

  it "should accept images as image attachment" do
    medium = Medium.new(:image => File.open("#{Rails.root}/spec/fixtures/files/image_c.jpg"))
    expect(medium).to be_valid
  end

  it "should return correct paths and urls" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/files/text_file.txt")
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{Rails.root}/public/content_types/text.gif")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql('/content_types/text.gif')

    medium.update(:image => File.open("#{Rails.root}/spec/fixtures/files/image_c.jpg"))
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/document.txt")
    expect(medium.path(:icon)).to eql("#{ENV['DATA_DIR']}/media/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/document.txt?#{medium.document.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")

    medium.update(:document => nil)
    medium.reload

    expect(medium.path(:original)).to eql("#{ENV['DATA_DIR']}/media/original/#{medium.ids}/image.jpg")
    expect(medium.path(:icon)).to eql("#{ENV['DATA_DIR']}/media/icon/#{medium.ids}/image.jpg")
    expect(medium.url(:original)).to eql("/media/images/original/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
    expect(medium.url(:icon)).to eql("/media/images/icon/#{medium.ids}/image.jpg?#{medium.image.updated_at}")
  end

  it "should read an escaped file uri to an existing file" do
    Medium.create :uri => "file:///#{Rails.root}/spec/fixtures/files/image_c.jpg"
    medium = Medium.last

    expect(medium.document.file?).to be_falsey
    expect(medium.to_file :image).not_to be_nil
    expect(medium.image.content_type).to eql('image/jpeg')
  end

  it "should not store the same file twice (hashing-check)" do
    Medium.create :document => File.open("#{Rails.root}/spec/fixtures/files/text_file.txt")
    medium = Medium.new :document => File.open("#{Rails.root}/spec/fixtures/files/text_file.txt")

    expect(medium.save).to be_falsey
    expect(medium.errors.full_messages).to eql(
      ['checksum a file with identical content already exists']
    )
  end

  it "should return the dummy when no files are attached" do
    medium = Medium.new
    expect(medium.save).to be_falsey
    expect(medium.errors[:document]).to eq(
      ['please select a file']
    )
  end

  it "should delete all files after destruction of an image" do
    medium = Medium.create :document => File.open("#{Rails.root}/spec/fixtures/files/image_c.jpg")
    medium = Medium.last

    paths = [:original, :icon, :thumbnail, :preview, :normal].map{ |s| medium.path(s) }

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
    expect(medium.datahash).to eq("84fa6bab000ea9d8f73cf27d2cee8ef593ee7277")
  end

  context 'content types' do
    it "should determine the processors according to the document content type" do
      medium = Medium.new
      expect(medium).to receive(:processors).and_call_original
      expect(medium.processors).to eq([])

      medium = FactoryBot.build(:picture_c).medium
      expect(medium.processors).to eq([])

      medium = FactoryBot.build(:video_a).medium
      expect(medium.processors).to eq([:video])

      medium = FactoryBot.build(:video_b).medium
      expect(medium.processors).to eq([:video])

      medium = FactoryBot.build(:audio_a).medium
      expect(medium.processors).to eq([:audio])

      medium = FactoryBot.build(:audio_b).medium
      expect(medium.processors).to eq([:audio])
    end

    it "should not run the video processor for images" do
      Dir["#{Rails.root}/lib/paperclip_processors/*"].sort.each{ |f| require f }

      expect(Paperclip::Video).not_to receive(:make)
      expect(Paperclip::Audio).not_to receive(:make)
      FactoryBot.create :picture_c
    end

    it "should run the video processor for videos" do
      expect(Paperclip::Video).to receive(:make).at_least(:once).and_call_original
      expect(Paperclip::Audio).not_to receive(:make)
      FactoryBot.create :video_a
    end

    it "should run the audio processor for audio" do
      expect(Paperclip::Video).not_to receive(:make)
      expect(Paperclip::Audio).to receive(:make).at_least(:once).and_call_original
      FactoryBot.create :audio_a
    end

    it "should convert a video to all 3 major html5 containers/codecs" do
      medium = FactoryBot.create :video_a
      document = medium.medium.document
      expect(File.size document.path(:mp4)).to be > 0
      expect(File.size document.path(:webm)).to be > 0
      expect(File.size document.path(:ogg)).to be > 0
    end

    it "should convert a audio file to all 2 major html5 containers/formats" do
      medium = FactoryBot.create :audio_a
      document = medium.medium.document
      expect(File.size document.path(:mp3)).to be > 0
      expect(File.size document.path(:ogg)).to be > 0
    end

    it "should destroy custom styles with the medium" do
      medium = FactoryBot.create :audio_a
      document = medium.medium.document
      paths = [document.path(:mp3), document.path(:ogg)]

      medium.reload.destroy
      expect(File.exist? paths[0]).to be_falsey
      expect(File.exist? paths[1]).to be_falsey
    end
  end
end

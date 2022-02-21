require 'rails_helper'

RSpec.describe Kor::Storage do
  it 'should guess the mime type' do
    content_type = described_class.guess_content_type('spec/fixtures/files/audio_a.wav')
    expect(content_type).to eq('audio/x-wav')

    content_type = described_class.guess_content_type('spec/fixtures/files/video_a.m4v')
    expect(content_type).to eq('video/x-m4v')

    content_type = described_class.guess_content_type('spec/fixtures/files/pdf_a.pdf')
    expect(content_type).to eq('application/pdf')

    content_type = described_class.guess_content_type('spec/fixtures/works.csv')
    expect(content_type).to eq('text/plain')
  end

  it 'should support the basic Medium workflow' do
    medium = picture_a.medium
    datahash = medium.datahash

    expect(medium.document).to be_a(Kor::Storage)
    expect(medium.image).to be_a(Kor::Storage)

    expect(medium.image.file?).to be_truthy
    expect(medium.image.file).to be_a(IO)
    expect(medium.image_content_type).to eq('image/jpeg')
    expect(medium.image_file_name).to eq('image_a.jpg')
    expect(medium.image_file_size).to eq(271993)
    expect(medium.image_updated_at).to be > 1.day.ago.to_i

    expect(medium.document.file?).to be_falsey
    expect(medium.document.file).to be_nil
    expect(medium.document_content_type).to be_nil
    expect(medium.document_file_name).to be_nil
    expect(medium.document_file_size).to be_nil
    expect(medium.document_updated_at).to be_nil


    medium.image = nil

    expect(medium.image.file?).to be_falsey
    expect(medium.image.file).to be_nil
    expect(medium.image_content_type).to be_nil
    expect(medium.image_file_name).to be_nil
    expect(medium.image_file_size).to be_nil
    expect(medium.image_updated_at).to be_nil

    expect(medium.save).to be_falsey
    expect(medium.errors[:document]).to eq(['please select a file'])

    medium.document = File.open("#{Rails.root}/spec/fixtures/files/image_c.jpg")

    expect(medium.document.file?).to be_truthy
    expect(medium.document.file).to be_a(IO)
    expect(medium.document_content_type).to eq('image/jpeg')
    expect(medium.document_file_name).to eq('image_c.jpg')
    expect(medium.document_file_size).to eq(398170)
    expect(medium.document_updated_at).to be > 1.day.ago.to_i

    expect(medium.image.file?).to be_falsey
    expect(medium.image.file).to be_nil
    expect(medium.image_content_type).to be_nil
    expect(medium.image_file_name).to be_nil
    expect(medium.image_file_size).to be_nil
    expect(medium.image_updated_at).to be_nil


    expect(medium.valid?).to be_truthy

    # document now moved to image
    expect(medium.document.file?).to be_falsey
    expect(medium.document.file).to be_nil
    expect(medium.document_content_type).to be_nil
    expect(medium.document_file_name).to be_nil
    expect(medium.document_file_size).to be_nil
    expect(medium.document_updated_at).to be_nil

    expect(medium.image.file?).to be_truthy
    expect(medium.image.file).to be_a(IO)
    expect(medium.image_content_type).to eq('image/jpeg')
    expect(medium.image_file_name).to eq('image_c.jpg')
    expect(medium.image_file_size).to eq(398170)
    expect(medium.image_updated_at).to be > 1.day.ago.to_i


    expect(medium.save).to be_truthy

    expect(medium.datahash).not_to eq(datahash)

    # no changes
    expect(medium.document.file?).to be_falsey
    expect(medium.document.file).to be_nil
    expect(medium.document_content_type).to be_nil
    expect(medium.document_file_name).to be_nil
    expect(medium.document_file_size).to be_nil
    expect(medium.document_updated_at).to be_nil

    expect(medium.image.file?).to be_truthy
    expect(medium.image.file).to be_a(IO)
    expect(medium.image_content_type).to eq('image/jpeg')
    expect(medium.image_file_name).to eq('image_c.jpg')
    expect(medium.image_file_size).to eq(398170)
    expect(medium.image_updated_at).to be > 1.day.ago.to_i
  end
end

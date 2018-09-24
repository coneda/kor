require 'rails_helper'

RSpec.describe AuthorityGroupCategory do

  it 'should be able to have a parent and children' do
    archive = FactoryGirl.create :archive

    expect(archive.parent).to be_nil
    expect(archive.children).to be_empty

    shelf_1 = FactoryGirl.create :shelf_1, parent: archive
    archive.reload

    expect(archive.parent).to be_nil
    expect(archive.children).to eq([shelf_1])
    expect(shelf_1.parent).to eq(archive)

    shelf_2 = FactoryGirl.create :shelf_2, parent: archive
    archive.reload

    expect(archive.children).to eq([shelf_1, shelf_2])
    expect(shelf_2.parent).to eq(archive)
  end

end
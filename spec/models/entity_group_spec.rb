require "rails_helper"

RSpec.describe EntityGroup do
  it "should load every kind of entities into the groups, not just images" do
    seminar.add_entities leonardo
    expect(seminar.entities.count).to eql(1)
  end

  it 'should not update entities when added to the group' do
    old_updated_at = leonardo.updated_at
    lecture.add_entities leonardo
    expect(leonardo.reload.updated_at).to eq(old_updated_at)

    old_updated_at = picture_b.updated_at
    lecture.add_entities picture_b
    expect(picture_b.reload.updated_at).to eq(old_updated_at)
  end
end

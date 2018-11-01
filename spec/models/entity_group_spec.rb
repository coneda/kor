require "rails_helper"

RSpec.describe EntityGroup do
  it "should load every kind of entities into the groups, not just images" do
    seminar.add_entities leonardo
    expect(seminar.entities.count).to eql(1)
  end
end
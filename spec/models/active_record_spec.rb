require 'rails_helper'

RSpec.describe ActiveRecord do
  it "should find or initialize with additional attributes" do
    u = User.find_or_initialize_by(name: "Gagamel")
    u.attributes = {email: "gagamel@schloss.com"}
    u.save
    gagamel = User.find_by_name("Gagamel")

    expect(gagamel.email).to eql("gagamel@schloss.com")
  end

  it "should take custom values for the timestamps" do
    timestamp = Time.now - 2.weeks
    User.create(name: "Gagamel", email: "gagamel@schloss.com", updated_at: timestamp)
    expect(User.find_by_name("Gagamel").updated_at).to be_within(5.seconds).of(timestamp)
  end

  it "does insert duplicate links for many-to-many associations" do
    group = FactoryBot.create :authority_group

    group.entities << Entity.first
    group.entities << Entity.first

    expect(group.entities.count).to eql(2)
  end

  it 'sets updated_at when creating and deleting' do
    mona_lisa = FactoryBot.create :mona_lisa
    ua1 = mona_lisa.updated_at
    expect(ua1).to be_within(1.second).of(Time.now)

    # due to mysql timestamp precision
    sleep 1

    mona_lisa.destroy
    ua2 = mona_lisa.updated_at
    expect(ua2).to be > ua1
  end
end

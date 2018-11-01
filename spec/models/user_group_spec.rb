require 'rails_helper'

RSpec.describe UserGroup do
  it "should not allow words longer than 30 characters for its name" do
    user_group = UserGroup.new(
      :owner => User.first,
      :name => "MySuperAnnoyinglyLongNameThatServesNoPurpose"
    )

    expect(user_group.valid?).to be_falsey
    expect(user_group.errors.full_messages).to include(
      "name cannot contain words longer than 30 characters"
    )
  end
end
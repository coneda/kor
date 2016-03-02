require 'rails_helper'

describe UserGroup do

  include DataHelper

  it "should not allow words longer than 30 characters for its name" do
    test_data_for_auth

    user_group = UserGroup.new(
      :owner => User.first,
      :name => "MySuperAnnoyinglyLongNameThatServesNoPurpose"
    )

    expect(user_group.valid?).to be_falsey
    expect(user_group.errors.full_messages).to include(
      "Name cannot contain words longer than 30 characters"
    )
  end

end
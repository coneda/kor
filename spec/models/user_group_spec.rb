require "spec_helper"

describe UserGroup do

  include DataHelper

  it "should not allow words longer than 30 characters for its name" do
    test_data_for_auth

    user_group = UserGroup.new(
      :owner => User.first,
      :name => "MySuperAnnoyinglyLongNameThatServesNoPurpose"
    )

    user_group.valid?.should be_false
    user_group.errors.full_messages.should include(
      "Name kann keine Wörter mit mehr als 30 Buchstaben enthalten"
    )
  end

end
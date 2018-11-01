require 'rails_helper'

RSpec.describe Grant do
  it "should have worked as expected during default_setup" do
    expect(admin.allowed_to?(:all, default, require: :all)).to be_truthy
    expect(admin.allowed_to?(:all, priv, require: :all)).to be_truthy

    policies = [:edit, :create, :delete, :download_originals, :tagging, :view_meta]
    expect(jdoe.allowed_to?(policies, default, require: :any)).to be_falsey
    expect(jdoe.allowed_to?(:view, default)).to be_truthy

    policies = [:view, :edit, :create, :delete, :download_originals, :tagging, :view_meta]
    expect(jdoe.allowed_to?(:all, priv, require: :any)).to be_falsey
  end

  it "should add a single grant" do
    expect {Kor::Auth.grant default, :edit, to: students}.to change{Grant.count}.by(1)
    expect(jdoe.allowed_to?([:view, :edit], default)).to be_truthy
  end

  it "should add several grants" do
    policies = [:edit, :create, :delete]
    expect {Kor::Auth.grant priv, policies, to: students}.to change{Grant.count}.by(3)
    expect(jdoe.allowed_to?(policies, priv, require: :all)).to be_truthy
  end

  it "should revoke a single grant" do
    expect {Kor::Auth.revoke default, :tagging, from: admins}.to change{Grant.count}.by(-1)
    expect(admin.allowed_to?(:tagging, default)).to be_falsey
  end

  it "should revoke several grants" do
    policies = [:tagging, :view_meta, :delete]
    expect {Kor::Auth.revoke default, policies, from: admins}.to change{Grant.count}.by(-3)
    expect(admin.allowed_to?(policies, default)).to be_falsey
  end
end
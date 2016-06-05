require 'rails_helper'

describe Kind do

  it "should manage settings" do
    k = Kind.new name: 'Pflanze', plural_name: 'Pflanzen'
    k.settings[:default_dating_label] = "Datierung"
    k.save
    
    expect(k.reload.settings[:default_dating_label]).to eql("Datierung")
  end

  it "should require a plural name" do
    k = Kind.new name: 'Person'
    expect(k.valid?).to be_falsey
    expect(k.errors[:plural_name].first).to eq("has to be filled in")
  end
  
end

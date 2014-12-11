require 'spec_helper'

describe Kind do

  it "should manage settings" do
    k = Kind.new :name => "Pflanze"
    k.settings[:default_dating_label] = "Datierung"
    k.save
    
    expect(k.reload.settings[:default_dating_label]).to eql("Datierung")
  end
  
end

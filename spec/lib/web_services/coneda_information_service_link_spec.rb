require "spec_helper"

describe WebServices::ConedaInformationServiceLink do

  it "should generate a simple link from an id" do
    entity = Entity.new
    entity.stub(:external_references).and_return("pnd" => "123123")

    described_class.link_for(entity).should == {
      "Gemeinsame Normdatei (GND)" => "http://d-nb.info/gnd/123123"
    }
  end

  it "should not fail with a failing request to the coneda servers" do
    entity = Entity.new
    entity.stub(:external_references).and_return("pnd" => "123 123")

    described_class.link_for(entity).should == {}
  end

end
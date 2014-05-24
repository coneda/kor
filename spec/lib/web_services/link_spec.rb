require 'spec_helper'

describe "WebServices::Links" do
  include DataHelper
  
  before :each do
    test_kinds
  
    @berlin = Entity.new(:name => 'Berlin', :kind => Kind.find_by_name('Ort') )
    @ldip = @literature_kind.entities.build(:name => 'Das Lexicon der Internetpioniere', :dataset => {'isbn' => '3896025058'})
    @person = @person_kind.entities.build(:name => 'Some Person', :external_references => {'pnd' => '123050936'})
  end
  
  it "should generate a correct link for 'Das Lexicon ...' (amazon)" do
    WebServices::AmazonLink.link_for(@ldip).should eql('http://www.amazon.com/gp/product/3896025058')
  end
  
  it "should generate a correct link for 'Berlin' (wikipedia)" do
    WebServices::WikipediaLink.link_for(@berlin).should eql('http://de.wikipedia.org/wiki/Spezial:Search?search=Berlin')
  end
  
  it "should generate coneda information service links" do
    WebServices::ConedaInformationServiceLink.link_for(@person).should == {
      "Deutschsprachige Wikipedia"=>"http://tools.wmflabs.org/persondata/redirect/gnd/de/123050936", 
      "Gemeinsame Normdatei (GND)"=>"http://d-nb.info/gnd/123050936"
    }
  end
  
end

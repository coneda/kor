# encoding: utf-8

require 'spec_helper'

describe Kor::Attachment do
  include DataHelper

  before :each do
    test_data_for_auth
    test_kinds
  end

  it "should provide a mongodb attachment for entities" do
    entity = Entity.make_unsaved(:person)
    entity.attachment.should be_a(Kor::Attachment)
  end
  
  it "should validate mongo attachments when saving the entity" do
    entity = Entity.make_unsaved(:person)
    entity.attachment.should_receive(:validate).once
    entity.save
  end
  
  it "should save mongo attachments when saving the entity" do
    entity = Entity.make_unsaved(:person)
    entity.attachment.should_receive(:save).twice
    entity.save
  end
  
  it "should set attachment_id for entities with a mongo attachment" do
    entity = Entity.make_unsaved(:person)
    entity.save
    
    entity.attachment_id.should_not be_nil
    entity.changed?.should be_false
  end
  
  it "should save mongo attributes when saving the entity and retrieve them after the entity has been reloaded" do
    entity = Entity.make_unsaved(:person)
    entity.attachment.document['label'] = 'something'
    entity.save
    
    entity = Entity.first
    entity.attachment.document['label'].should eql('something')
  end

  it "should save properties within the mongo attachment of entities" do
    entity = Entity.make_unsaved(:person, :properties => [
      {:label => 'age', :value => 15},
      {:label => 'height', :value => 12.7}
    ])
    
    entity.attachment.document['properties'].should eql([
      {:label => 'age', :value => 15},
      {:label => 'height', :value => 12.7}    
    ])
  end

  it "should save properties within the mongo attachment of entities and have them ready after reloading the entity" do
    entity = Entity.make(:person, :properties => [
      {'label' => 'age', 'value' => 15},
      {'label' => 'height', 'value' => 12.7}
    ])
    
    entity = Entity.last
    entity.attachment.document['properties'].should == [
      {'label' => 'age', 'value' => 15},
      {'label' => 'height', 'value' => 12.7}
    ]
  end
  
  it "should save synonyms within the mongo attachment of entities and have them ready after reloading the entity" do
    entity = Entity.make(:person, :synonyms => ['Leo', 'Leonardo'])
  
    entity = Entity.last
    entity.attachment.document['synonyms'].should == ['Leo', 'Leonardo']
  end
  
  it "should validate entity properties with the mongo class validator" do
    entity = Entity.make_unsaved(:person, :properties => [
      {'label' => 'age'},
      {'value' => 12.7}
    ])
    entity.valid?.should be_false
    entity.errors.full_messages.should include('weitere Eigenschaften benötigen einen Wert')
    entity.errors.full_messages.should include('weitere Eigenschaften benötigen einen Bezeichner')
  end
  
  it "should handle updates to entities" do
    entity = Entity.make(:person, :properties => [
      {'label' => 'age', 'value' => 15},
      {'label' => 'height', 'value' => 12.7}
    ])
    entity.properties << {'label' => 'dreck', 'value' => 'am stecken'}
    entity.attachment.document['properties'].should == [
      {'label' => 'age', 'value' => 15},
      {'label' => 'height', 'value' => 12.7},
      {'label' => 'dreck', 'value' => 'am stecken'}
    ]
    entity.save
    
    entity = Entity.last
    entity.properties.should == [
      {'label' => 'age', 'value' => 15},
      {'label' => 'height', 'value' => 12.7},
      {'label' => 'dreck', 'value' => 'am stecken'}
    ]
  end
  
  it "should retrieve unsaved mongo values without a kind" do
    entity = Entity.new
    entity.set_attachment_value 'test', 'test_value'
    entity.get_attachment_value('test').should eql('test_value')
  end
  
  it "should destroy the mongo attachment when the entity is destroyed" do
    entity = Entity.make(:person, :synonyms => ['Leonardo da Vinci'])
    collection = Kor::Attachment.collection
    collection.find('_id' => BSON::ObjectId.from_string(entity.attachment_id)).first.should_not be_nil
    entity.destroy
    collection.find('_id' => BSON::ObjectId.from_string(entity.attachment_id)).first.should be_nil
    
    entity = Entity.make(:person)
    entity.destroy
    collection.find.count.should eql(0)
  end
  
  it "should maintain an entity_id of the associated entity" do
    entity = Entity.make(:person, :synonyms => ['Leonardo da Vinci'])
    entity = Entity.last
    entity.attachment.entity_id.should eql(entity.id)
  end
  
  it "should search by synonyms" do
    entity = Entity.make(:person, :synonyms => ['Leonardo da Vinci'])
    Kor::Attachment.find_by_synonym("Vinci").count.should_not == 0
    Kor::Attachment.find_by_synonym("Leonardo").count.should_not == 0
    Kor::Attachment.find_by_synonym("ardo").count.should_not == 0
  end

  it "should have correct attachment values after saving" do
    entity = FactoryGirl.create :jack, :synonyms => ["The Hammer"]
    expect(entity.synonyms).to eq(["The Hammer"])
  end

end

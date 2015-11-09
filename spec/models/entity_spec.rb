# encoding: utf-8

require 'rails_helper'

describe Entity do
  include DataHelper

  before :each do
    test_data
    
    Kor.config.update 'app' => {
      'gallery' => {
        'primary_relations' => ['shows'], 
        'secondary_relations' => ['has been created by']
    }}
  end

  it "should find entities by two or more relationships" do
    last_supper = FactoryGirl.create :work, :name => "Das Letzte Abendmahl"
    leonardo = FactoryGirl.create :leonardo
    louvre = FactoryGirl.create :institution, :name => 'Louvre'
    Relationship.relate_and_save(@mona_lisa, 'has been created by', leonardo)
    Relationship.relate_and_save(last_supper, 'has been created by', leonardo)
    Relationship.relate_and_save(@mona_lisa, 'is located at', louvre)
    
    work_kind_id = Kind.find_by_name('Werk').id
    @query = Kor::Graph.new(:user => User.admin).search(:attribute,
      :criteria => {
        :kind_id => work_kind_id,
        :relationships => [
          { :relation_name => 'is located at', :entity_name => 'louvre'},
          { :relation_name => 'has been created by', :entity_name => 'leo'}
        ]
      },
      :page => 1
    )
    
    result = @query.results.items
    expect(result.size).to eql(2)
    expect(result.last).to eql(@mona_lisa)
    expect(result.first).to eql(last_supper)
  end

  it "should accept nested attributes for entity datings" do
    leonardo = FactoryGirl.create :leonardo, :new_datings_attributes => [
      { :label => 'Datierung',  :dating_string => "15. Jahrhundert" },
      { :label => 'Datierung',  :dating_string => "15.12.1933" }
    ]
    expect(leonardo.datings.count).to eql(2)
  end
  
  it "should search by dating" do
    nurnberg = FactoryGirl.create :location, :name => "Nürnberg", :datings => [
      FactoryGirl.build(:entity_dating, :dating_string => "15. Jahrhundert"),
      FactoryGirl.build(:entity_dating, :dating_string => "18. Jahrhundert"),
      FactoryGirl.build(:entity_dating, :dating_string => "544")
    ]
    
    expect(Entity.dated_in("1534").count).to be_zero
    expect(Entity.dated_in("1433").count).to eql(1)
    expect(Entity.dated_in("544").count).to eql(1)
    expect(Entity.dated_in("300 bis 1900").all).to include(nurnberg)
  end
  
  it "should raise an error if the options for the related method are invalid" do
    entity = FactoryGirl.build :work
    
    expect { entity.related(:assume => :terciary) }.to raise_error
    expect { entity.related(:assume => :image, :search => :secondary) }.to raise_error
  end
  
  it "should find related media for primary entities and vice versa" do
    image = FactoryGirl.create :image_a
    Relationship.relate_and_save(@mona_lisa, 'is shown by', image)
    
    expect(@mona_lisa.related(:search => :media, :assume => :primary)).to eql([image])
    expect(image.related(:search => :primary, :assume => :media)).to eql([@mona_lisa])
  end
  
  it "should find related primary entities for secondary entities and vice versa" do
    @leonardo = FactoryGirl.create :leonardo
    Relationship.relate_and_save(@mona_lisa, 'has been created by', @leonardo)
    
    expect(@leonardo.related(:search => :primary, :assume => :secondary)).to eql([@mona_lisa])
    expect(@mona_lisa.related(:search => :secondary, :assume => :primary)).to eql([@leonardo])
  end
  
  it "should find related primary entities for secondary entities" do
    image = FactoryGirl.create :image_a
    @leonardo = FactoryGirl.create :leonardo
    Relationship.relate_and_save(@mona_lisa, 'is shown by', image)
    Relationship.relate_and_save(@mona_lisa, 'has been created by', @leonardo)
    
    expect(@leonardo.related(:search => :media, :assume => :secondary)).to eql([image])
  end
  
  it "should have an uuid when saved without validation" do
    entity = Kind.find_by_name("Ort").entities.build(:name => "Nürnberg")
    entity.save(:validate => false)
    expect(entity.uuid).not_to be_nil
  end
  
  it "should generate correct kind names" do
    entity = Kind.find_by_name("Ort").entities.build(:name => "Nürnberg")
    expect(entity.kind_name).to eql("Ort")
    entity.subtype = "Städtchen"
    expect(entity.kind_name).to eql("Ort (Städtchen)")
  end
  
  it "should save with serial numbers" do
    entities = [
      FactoryGirl.build(:location, :name => 'Nürnberg'),
      FactoryGirl.build(:location, :name => 'Nürnberg'),
      FactoryGirl.build(:location, :name => 'Nürnberg')
    ]
    
    entities.each do |e|
      unless e.save_with_serial
        puts e.errors.full_messages.inspect
        puts e.name
        puts e.distinct_name
        fail
      end
    end
    
    expect(entities.map{|e| {:name => e.name, :distinct_name => e.distinct_name}}).to eq([
      {:name => 'Nürnberg', :distinct_name => nil},
      {:name => 'Nürnberg', :distinct_name => '2'},
      {:name => 'Nürnberg', :distinct_name => '3'}
    ])
  end
  
  it "should save with serial with existing distinct name" do
    entities = [
      FactoryGirl.build(:location, :name => 'Nürnberg', :distinct_name => 'Bayern'),
      FactoryGirl.build(:location, :name => 'Nürnberg', :distinct_name => 'Bayern'),
      FactoryGirl.build(:location, :name => 'Nürnberg', :distinct_name => 'Bayern')
    ]
    
    entities.each do |e|
      unless e.save_with_serial
        puts e.errors.full_messages.inspect
        puts e.name
        puts e.distinct_name
        fail
      end
    end
    
    expect(entities.map{|e| {:name => e.name, :distinct_name => e.distinct_name}}).to eq([
      {:name => 'Nürnberg', :distinct_name => "Bayern"},
      {:name => 'Nürnberg', :distinct_name => "Bayern – 2"},
      {:name => 'Nürnberg', :distinct_name => 'Bayern – 3'}
    ])
  end
  
  it "should not allow to create an entity twice" do
    entity = Kind.find_by_name('Werk').entities.build(
      :name => "Mona Lisa",
      :collection => Collection.first,
      :distinct_name => ""
    )
    
    expect(entity.valid?).to be_falsey
    expect(entity.errors.full_messages).to eq([
      'name is already taken',
      'distinguished name is invalid'
    ])
  end

  it "should fire elastic updates" do
    expect(Kor::Elastic).to receive(:index).exactly(2).times
    expect(Kor::Elastic).to receive(:drop)

    entity = FactoryGirl.create :der_schrei
    entity.update_attributes :comment => "Some comment"
    entity.destroy
  end

  it "should allow an attachment" do
    entity = FactoryGirl.create :jack

    expect(entity.dataset).to eq({})
    expect(entity.synonyms).to eq([])
    expect(entity.properties).to eq([])
  end

  it "should allow attachments to be written to" do
    entity = FactoryGirl.create :jack

    entity.update_attributes(
      :dataset => {"some" => "value"},
      :synonyms => ["john"],
      :properties => [{'label' => 'page', 'value' => 144}]
    )

    entity.reload

    expect(entity.dataset).to eq({"some" => "value"})
    expect(entity.synonyms).to eq(["john"])
    expect(entity.properties).to eq([{'label' => 'page', 'value' => 144}])
  end

  it "should validate the dataset" do
    entity = FactoryGirl.build :jack
    expect(entity).to receive(:validate_dataset).once
    expect(entity).to receive(:validate_properties).once
    entity.save
  end

  it "should validate entity properties with the mongo class validator" do
    entity = FactoryGirl.build :jack, :properties => [
      {'label' => 'age'},
      {'value' => 12.7}
    ]
    expect(entity.valid?).to be_falsey
    expect(entity.errors.full_messages).to include('further properties need a value')
    expect(entity.errors.full_messages).to include('further properties need a label')
  end

  it "should retrieve unsaved mongo values without a kind" do
    entity = Entity.new
    entity.properties = [{'label' => 'test', 'value' => 'test_value'}]
    expect(entity.properties).to eq([{'label' => 'test', 'value' => 'test_value'}])
  end

  it "should have correct attachment values after saving" do
    entity = FactoryGirl.create :jack, :synonyms => ["The Hammer"]
    expect(entity.synonyms).to eq(["The Hammer"])
  end

  it "should validate the dataset" do
    people = Kind.where(:name => "person").first
    people.fields << FactoryGirl.create(:isbn)

    entity = FactoryGirl.build :jack, :dataset => {'isbn' => 'invalid ISBN'}
    expect(entity.save).to be_falsey
    expect(entity.errors.full_messages).to include("ISBN is invalid")
  end

  it "should validate against needless spaces" do
    leonardo = FactoryGirl.build :leonardo
    expect(leonardo.valid?).to be_truthy

    leonardo.name = " Leonardo"
    expect(leonardo.valid?).to be_falsey
    expect(leonardo.errors.full_messages.first).to eq(
      "name can't start with a space"
    )

    leonardo.name = "Leonardo "
    expect(leonardo.valid?).to be_falsey
    expect(leonardo.errors.full_messages.first).to eq(
      "name can't end with a space"
    )

    leonardo.name = "Leonardo  da Vinci"
    expect(leonardo.valid?).to be_falsey
    expect(leonardo.errors.full_messages.first).to eq(
      "name can't contain consecutive spaces"
    )
  end

end

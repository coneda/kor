# encoding: utf-8

require 'spec_helper'

describe Entity do
  include DataHelper

  before :each do
    test_data
    
    Kor.config.update 'app' => {
      'gallery' => {
        'primary_relations' => ['stellt dar'], 
        'secondary_relations' => ['wurde erschaffen von']
    }}
  end
  
  it "should only update when setting new external references" do
    entity = Entity.new(:external_references => {:pnd => '12345'})
    entity.external_references = {:knd => '6789'}
    entity.external_references.should eql(:pnd => '12345', :knd => '6789')
    
    entity.external_references = {:pnd => '6789'}
    entity.external_references.should eql(:pnd => '6789', :knd => '6789')
  end
  
  it "should find entities by two or more relationships" do
    mona_lisa = Kind.find_by_name('Werk').entities.make(:name => 'Mona Lisa2')
    last_supper = Kind.find_by_name('Werk').entities.make(:name => 'Das Letzte Abendmahl')
    leonardo = Kind.find_by_name('Person').entities.make(:name => 'Leonardo')
    louvre = Entity.make(:name => 'Louvre', :kind => Kind.find_by_name('Ort'))
    Relationship.relate_and_save(mona_lisa, 'wurde erschaffen von', leonardo)
    Relationship.relate_and_save(last_supper, 'wurde erschaffen von', leonardo)
    Relationship.relate_and_save(mona_lisa, 'befindet sich in', louvre)
    
    work_kind_id = Kind.find_by_name('Werk').id
    @query = Kor::Graph.new(:user => User.admin).search(:attribute,
      :criteria => {
        :kind_id => work_kind_id,
        :relationships => [
          { :relation_name => 'befindet sich in', :entity_name => 'louvre'},
          { :relation_name => 'wurde erschaffen von', :entity_name => 'leo'}
        ]
      },
      :page => 1
    )
    
    result = @query.results.items
    result.size.should eql(1)
    result.first.should eql(mona_lisa)
  end

  it "should accept nested attributes for entity datings" do
    roma = Kind.find_by_name("Ort").entities.make(:name => "Roma", :new_datings_attributes => [
      { :label => 'Datierung',  :dating_string => "15. Jahrhundert" },
      { :label => 'Datierung',  :dating_string => "15.12.1933" }
    ])
    roma.datings.count.should eql(2)
  end
  
  it "should search by dating" do
    nurnberg = Kind.find_by_name("Ort").entities.make(:name => "Nurnberg", :datings => [
      EntityDating.make(:dating_string => "15. Jahrhundert"),
      EntityDating.make(:dating_string => "18. Jahrhundert"),
      EntityDating.make(:dating_string => "544")
    ])
    
    Entity.dated_in("1534").count.should be_zero
    Entity.dated_in("1433").count.should eql(1)
    Entity.dated_in("544").count.should eql(1)
    Entity.dated_in("300 bis 1900").count.should eql(3) # includes 2 default entities from the data helper
  end
  
  it "should raise an error if the options for the related method are invalid" do
    entity = mock_model(Entity)
    
    lambda { entity.related(:assume => :terciary) }.should raise_error
    lambda { entity.related(:assume => :image, :search => :secondary) }.should raise_error
  end
  
  it "should find related media for primary entities and vice versa" do
    image = Entity.make(:medium, :medium => Medium.make_unsaved)
    Relationship.relate_and_save(@mona_lisa, 'wird dargestellt von', image)
    
    @mona_lisa.related(:search => :media, :assume => :primary).should eql([image])
    image.related(:search => :primary, :assume => :media).should eql([@mona_lisa])
  end
  
  it "should find related primary entities for secondary entities and vice versa" do
    @leonardo = Entity.make(:kind => @person_kind, :name => 'Leonardo da Vinci')
    Relationship.relate_and_save(@mona_lisa, 'wurde erschaffen von', @leonardo)
    
    @leonardo.related(:search => :primary, :assume => :secondary).should eql([@mona_lisa])
    @mona_lisa.related(:search => :secondary, :assume => :primary).should eql([@leonardo])
  end
  
  it "should find related primary entities for secondary entities" do
    image = Entity.make(:medium, :medium => Medium.make_unsaved)
    @leonardo = Entity.make(:kind => @person_kind, :name => 'Leonardo da Vinci')
    Relationship.relate_and_save(@mona_lisa, 'wird dargestellt von', image)
    Relationship.relate_and_save(@mona_lisa, 'wurde erschaffen von', @leonardo)
    
    @leonardo.related(:search => :media, :assume => :secondary).should eql([image])
  end
  
  it "should have an uuid when saved without validation" do
    entity = Kind.find_by_name("Ort").entities.build(:name => "Nürnberg")
    entity.save(:validate => false)
    entity.uuid.should_not be_nil
  end
  
  it "should generate correct kind names" do
    entity = Kind.find_by_name("Ort").entities.build(:name => "Nürnberg")
    entity.kind_name.should eql("Ort")
    entity.subtype = "Städtchen"
    entity.kind_name.should eql("Ort (Städtchen)")
  end
  
  it "should save with serial numbers" do
    kind = Kind.find_by_name("Ort")
    entities = [
      kind.entities.make_unsaved(:name => "Nürnberg"),
      kind.entities.make_unsaved(:name => "Nürnberg"),
      kind.entities.make_unsaved(:name => "Nürnberg")
    ]
    
    entities.each do |e|
      unless e.save_with_serial
        puts e.errors.full_messages.inspect
        puts e.name
        puts e.distinct_name
        fail
      end
    end
    
    entities.map{|e| {:name => e.name, :distinct_name => e.distinct_name}}.should == [
      {:name => 'Nürnberg', :distinct_name => nil},
      {:name => 'Nürnberg', :distinct_name => '2'},
      {:name => 'Nürnberg', :distinct_name => '3'}
    ]
  end
  
  it "should save with serial with existing distinct name" do
    kind = Kind.find_by_name("Ort")
    entities = [
      kind.entities.make_unsaved(:name => "Nürnberg", :distinct_name => 'Bayern'),
      kind.entities.make_unsaved(:name => "Nürnberg", :distinct_name => 'Bayern'),
      kind.entities.make_unsaved(:name => "Nürnberg", :distinct_name => 'Bayern')
    ]
    
    entities.each do |e|
      unless e.save_with_serial
        puts e.errors.full_messages.inspect
        puts e.name
        puts e.distinct_name
        fail
      end
    end
    
    entities.map{|e| {:name => e.name, :distinct_name => e.distinct_name}}.should == [
      {:name => 'Nürnberg', :distinct_name => "Bayern"},
      {:name => 'Nürnberg', :distinct_name => "Bayern – 2"},
      {:name => 'Nürnberg', :distinct_name => 'Bayern – 3'}
    ]
  end
  
  it "should not allow to create an entity twice" do
    entity = Kind.find_by_name('Werk').entities.build(
      :name => "Mona Lisa",
      :collection => Collection.first,
      :distinct_name => ""
    )
    
    entity.valid?.should be_false
    entity.errors.full_messages.should == [
      'Name ist bereits vergeben',
      'eindeutiger Name ist ungültig'
    ]
  end

  it "should fire elastic updates" do
    expect(Kor::Elastic).to receive(:index).exactly(2).times
    expect(Kor::Elastic).to receive(:drop)

    entity = FactoryGirl.create :der_schrei
    entity.update_attributes :comment => "Some comment"
    entity.destroy
  end
  
end

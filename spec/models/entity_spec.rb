require 'rails_helper'

RSpec.describe Entity do
  it "should accept nested attributes for entity datings" do
    leonardo.update datings_attributes: [
      {label: 'Datierung', dating_string: "15. Jahrhundert"},
      {label: 'Datierung', dating_string: "15.12.1933"}
    ]
    expect(leonardo.datings.count).to eql(3)
  end

  it "should search by dating" do
    paris.update(
      datings: [
        FactoryBot.build(:entity_dating, :dating_string => "15. Jahrhundert"),
        FactoryBot.build(:entity_dating, :dating_string => "18. Jahrhundert"),
        FactoryBot.build(:entity_dating, :dating_string => "544")
      ]
    )

    expect(Entity.dated_in('1534')).not_to include(paris)
    expect(Entity.dated_in('1433').count).to eql(1)
    expect(Entity.dated_in('544').count).to eql(1)
    expect(Entity.dated_in('300 bis 1900').all).to include(paris)
  end

  it "should have an uuid when saved without validation" do
    entity = locations.entities.build(name: "Nürnberg")
    entity.save(validate: false)
    expect(entity.uuid).not_to be_nil
  end

  it "should generate correct kind names" do
    entity = locations.entities.build(name: "Nürnberg")
    expect(entity.kind_name).to eql("location")
    entity.subtype = "village"
    expect(entity.kind_name).to eql("location (village)")
  end

  it "should fire elastic updates", elastic: true do
    expect(Kor::Elastic).to receive(:index).exactly(2).times
    expect(Kor::Elastic).to receive(:drop)

    entity = FactoryBot.create :der_schrei
    entity.update :comment => "Some comment"
    entity.destroy
  end

  it "should allow an attachment" do
    entity = FactoryBot.create :jack

    expect(entity.dataset).to eq({})
    expect(entity.synonyms).to eq([])
    expect(entity.properties).to eq([])
  end

  it "should allow attachments to be written to" do
    entity = FactoryBot.create :jack

    entity.update(
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
    entity = FactoryBot.build :jack
    expect(entity).to receive(:validate_dataset).once
    expect(entity).to receive(:validate_properties).once
    entity.save
  end

  it "should validate entity properties with the mongo class validator" do
    entity = FactoryBot.build :jack, :properties => [
      {'label' => 'age'},
      {'value' => 12.7}
    ]
    expect(entity.valid?).to be_falsey
    expect(entity.errors.full_messages[0]).to match(
      /further properties format invalid/
    )
  end

  it "should retrieve unsaved mongo values without a kind" do
    entity = Entity.new
    entity.properties = [{'label' => 'test', 'value' => 'test_value'}]
    expect(entity.properties).to eq([{'label' => 'test', 'value' => 'test_value'}])
  end

  it "should have correct attachment values after saving" do
    entity = FactoryBot.create :jack, :synonyms => ["The Hammer"]
    expect(entity.synonyms).to eq(["The Hammer"])
  end

  it "should validate the dataset" do
    people = Kind.where(name: "Person").first
    people.fields << FactoryBot.create(:isbn)

    entity = FactoryBot.build :jack, dataset: {'isbn' => 'invalid ISBN'}
    expect(entity.save).to be_falsey
    expect(entity.errors.full_messages).to include("Dataset isbn is invalid")
  end

  it "should validate against needless spaces" do
    leo = leonardo
    expect(leo.valid?).to be_truthy

    leo.name = " Leonardo"
    expect(leo.valid?).to be_falsey
    expect(leo.errors.full_messages.first).to eq(
      "name can't start with a space"
    )

    leo.name = "Leonardo "
    expect(leo.valid?).to be_falsey
    expect(leo.errors.full_messages.first).to eq(
      "name can't end with a space"
    )

    leo.name = "Leonardo  da Vinci"
    expect(leo.valid?).to be_falsey
    expect(leo.errors.full_messages.first).to eq(
      "name can't contain consecutive spaces"
    )
  end

  it "should ensure unique names within the same collection and kind" do
    entity = Entity.new name: 'Leonardo', kind_id: people.id, collection_id: default.id
    expect(entity.valid?).to be_falsey
    expect(entity.errors.full_messages).to include(
      'name is already taken',
      'distinguished name is invalid'
    )
  end

  it "should ensure unique names within the same kind but different collections" do
    entity = Entity.new name: 'Leonardo', kind_id: people.id, collection_id: priv.id
    expect(entity.valid?).to be_falsey
    expect(entity.errors.full_messages).to include('name is already taken')
  end

  it "should allow equal names within different kinds and the same collection" do
    entity = Entity.new name: 'Leonardo', kind_id: locations.id, collection_id: default.id
    expect(entity.valid?).to be_truthy
  end

  specify "relationships should be destroyed along with the entity" do
    expect{
      leonardo.destroy
    }.to change{ Relationship.count }.by(-2)
  end

  specify "directed relationships should be destroyed along with the entity" do
    expect{
      leonardo.destroy
    }.to change{ DirectedRelationship.count }.by(-4)
  end

  it 'should retrieve entities by an array of ids keeping the order' do
    ml = FactoryBot.create :mona_lisa
    ds = FactoryBot.create :der_schrei

    expect(Entity.by_ordered_id_array(ml.id, ds.id).pluck(:id)).to eq([ml.id, ds.id])
    expect(Entity.by_ordered_id_array([ml.id, ds.id]).pluck(:id)).to eq([ml.id, ds.id])
    expect(Entity.by_ordered_id_array(ds.id, ml.id).pluck(:id)).to eq([ds.id, ml.id])
    expect(Entity.by_ordered_id_array([ds.id, ml.id]).pluck(:id)).to eq([ds.id, ml.id])

    expect{
      Entity.includes(:kind).by_relation_name('related to').by_ordered_id_array(1, 2).to_a
    }.not_to raise_error

    expect{
      Entity.by_ordered_id_array([]).to_a
    }.not_to raise_error
  end

  it 'should not be a medium by default' do
    expect(subject.is_medium?).to be_falsey
  end

  it "should not be a medium when the kind id is set to people's id" do
    subject.kind_id = people.id
    expect(subject.is_medium?).to be_falsey
  end

  it "should not be a medium when the kind is set to people" do
    subject.kind = people
    expect(subject.is_medium?).to be_falsey
  end

  it 'should be a medium when the medium_id attribute is set' do
    subject.medium_id = 12
    expect(subject.is_medium?).to be_truthy
  end

  it 'should be a medium when the medium attribute is set' do
    subject.medium = Medium.new
    expect(subject.is_medium?).to be_truthy
  end

  it 'should allow more than one entity without a name' do
    a = works.entities.create(
      collection: default,
      name: '',
      no_name_statement: 'unknown'
    )
    expect(a).to be_valid

    b = works.entities.create(
      collection: default,
      name: '',
      no_name_statement: 'unknown'
    )
    expect(b).to be_valid
  end

  it "should add tags 'tintenfass' and 'tintenfaß'" do
    # The name column on tags has a unique key which uses the collation for
    # checks of uniqueness. Therefore, we needed to change the collation to
    # binary

    expect{
      mona_lisa.update tag_list: ['tintenfass']
      mona_lisa.update tag_list: ['tintenfaß']
    }.not_to raise_error
  end
end

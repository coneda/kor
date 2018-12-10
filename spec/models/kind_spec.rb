require 'rails_helper'

RSpec.describe Kind do
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

  it 'should require unique naming' do
    kind = Kind.new name: 'work', plural_name: 'works'
    expect(kind).not_to be_valid
    expect(kind.errors[:name]).to include('is already taken')
    expect(kind.errors[:plural_name]).not_to include('is already taken')
  end

  it 'should destroy dependent records' do
    expect(Generator.count).to eq(1)
    expect(Field.count).to eq(4)
    expect(Entity.count).to eq(7)

    people.destroy

    expect(Kind.count).to eq(4)
    expect(Generator.count).to eq(0)
    expect(Field.count).to eq(2)
    expect(Entity.count).to eq(6)
  end

  it 'should soft-delete items' do
    works.destroy
    expect(Kind.count).to eq(4)
    expect(Kind.with_deleted.count).to eq(5)
  end

  it 'should validate correctly despite soft-deleted duplicates' do
    works.destroy

    kind = Kind.new name: 'work', plural_name: 'works'
    expect(kind).to be_valid
    kind.save

    expect(Kind.with_deleted.count).to eq(6)
  end

  it 'should set updated_at when deleted' do
    sleep 1.1
    works.destroy

    works = Kind.with_deleted.find_by name: 'work'

    expect(works.created_at).to be < works.updated_at
    expect(works.deleted_at).to eq(works.updated_at)
  end

  it 'should save the schema as nil when an empty string is given' do
    works.update schema: 'something'
    expect(works.reload.schema).to eq('something')
    works.update schema: ''
    expect(works.reload.schema).to eq(nil)
    works.update schema: nil
    expect(works.reload.schema).to eq(nil)
  end

  it 'should validate' do
    kind = Kind.new
    expect(kind.valid?).to be_falsey
    expect(kind.errors[:name]).to include('has to be filled in')
    expect(kind.errors[:plural_name]).to include('has to be filled in')
  end

  it 'should ignore addition of non-existing parents' do
    people.update parent_ids: 99
    expect(people.parent_ids).to be_empty
  end
end

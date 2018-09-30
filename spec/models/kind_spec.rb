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
    @works = FactoryGirl.create :works

    kind = Kind.new name: 'Werk', plural_name: 'Werke'
    expect(kind).not_to be_valid
    expect(kind.errors[:name]).to include('is already taken')
    expect(kind.errors[:plural_name]).not_to include('is already taken')
  end

  it 'should destroy dependent records' do
    people = FactoryGirl.create(:people,
      fields: [FactoryGirl.create(:field)],
      generators: [FactoryGirl.create(:language_indicator)]
    )

    FactoryGirl.create :leonardo
    
    expect(Generator.count).to eq(1)
    expect(Field.count).to eq(1)
    expect(Entity.count).to eq(1)

    people.destroy

    expect(Kind.count).to eq(0)
    expect(Generator.count).to eq(0)
    expect(Field.count).to eq(0)
    expect(Entity.count).to eq(0)
  end

  it 'should soft-delete items' do
    works = FactoryGirl.create :works
    people = FactoryGirl.create :people

    works.destroy
    expect(Kind.count).to eq(1)
    expect(Kind.with_deleted.count).to eq(2)
  end

  it 'should validate correctly despite soft-deleted duplicates' do
    @works = FactoryGirl.create :works
    @works.destroy

    kind = Kind.new name: 'Werk', plural_name: 'Werke'
    expect(kind).to be_valid
    kind.save

    expect(Kind.with_deleted.count).to eq(2)
  end

  it 'should set updated_at when deleted' do
    @works = FactoryGirl.create :works
    sleep 1.1
    @works.destroy

    works = Kind.with_deleted.find_by name: 'Werk'

    expect(works.created_at).to be < works.updated_at
    expect(works.deleted_at).to eq(works.updated_at)
  end

  it 'should save the schema as nil when an empty string is given' do
    @works = FactoryGirl.create :works
    @works.update schema: 'something'
    expect(@works.reload.schema).to eq('something')
    @works.update schema: ''
    expect(@works.reload.schema).to eq(nil)
    @works.update schema: nil
    expect(@works.reload.schema).to eq(nil)
  end

  # TODO: make sure these are implemented here as model specs, instead of 
  # controller specs
  # it 'should create a sub kind' do
  #   post :create, kind: {
  #     name: 'person',
  #     plural_name: 'people',
  #     parent_ids: [@media.id]
  #   }
  #   expect(response.status).to eq(200)
  #   expect(data['record']['parent_ids']).to eq([@media.id])
  # end

  # it 'should update a kind' do
  #   @people = FactoryGirl.create :people

  #   patch :update, id: @people.id, kind: {
  #     name: 'artists',
  #     parent_ids: [@media.id]
  #   }
  #   expect(response.status).to eq(200)
  #   expect(data['record']['name']).to eq('artists')
  #   expect(data['record']['parent_ids']).to eq([@media.id])
  # end

  # it 'should move a kind' do
  #   @people = FactoryGirl.create :people
  #   @works = FactoryGirl.create :works, parent_ids: [@people.id]

  #   patch :update, id: @works.id, kind: {
  #     parent_ids: [@media.id]
  #   }
  #   expect(response.status).to eq(200)
  #   expect(data['record']['parent_ids']).to eq([@media.id])
  # end

  # it 'should render errors when the plural name is missing' do
  #   post :create, kind: {
  #     name: 'person'
  #   }
  #   expect(response.status).to eq(406)
  #   expect(data['errors']['plural_name']).to include('has to be filled in')
  # end

  # it 'should ignore addition of non-existing parents' do
  #   @people = FactoryGirl.create :people

  #   patch :update, id: @people.id, kind: {parent_ids: 99}
  #   expect(response.status).to eq(200)
  #   expect(data['record']['parent_ids']).to be_empty
  # end

end

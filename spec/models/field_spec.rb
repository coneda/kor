require 'rails_helper'

describe Field do
  
  it "should synchronize the value for is_identifier across all kinds" do
    people = FactoryGirl.create :people, fields: [
      Field.new(name: 'viaf_id', show_label: 'stack')
    ]
    works = FactoryGirl.create :works, fields: [
      Field.new(name: 'viaf_id', show_label: 'stack', is_identifier: true)
    ]
    expect(people.reload.fields.first.is_identifier).to be_truthy

    people.fields.first.update_attributes is_identifier: false
    expect(works.reload.fields.first.is_identifier).to be_falsy

    works.fields.first.update_attributes is_identifier: true
    expect(people.reload.fields.first.is_identifier).to be_truthy
  end

  it "should synchronize storage on entities with the field name attribute" do
    Delayed::Worker.delay_jobs = false

    works = FactoryGirl.create :works, fields: [
      Field.new(name: 'viaf_id', show_label: 'stack', is_identifier: true)
    ]
    mona_lisa = FactoryGirl.create :mona_lisa, :dataset => {'viaf_id' => '1234'}
    der_schrei = FactoryGirl.create :der_schrei, :dataset => {'viaf_id' => '5678'}

    works.fields.first.update_attributes name: 'viaf'

    expect(mona_lisa.reload.dataset['viaf']).to eq('1234')
    expect(der_schrei.reload.dataset['viaf']).to eq('5678')

    works.fields.first.destroy

    expect(mona_lisa.reload.dataset['viaf']).to be_nil
    expect(der_schrei.reload.dataset['viaf']).to be_nil
  end

end
require 'rails_helper'

RSpec.describe Field do
  it "should synchronize the value for is_identifier across all kinds" do
    people.update fields: [
      Field.new(name: 'viaf_id', show_label: 'stack')
    ]
    works.update fields: [
      Field.new(name: 'viaf_id', show_label: 'stack', is_identifier: true)
    ]
    expect(people.reload.fields.first.is_identifier).to be_truthy

    people.fields.first.update_attributes is_identifier: false
    expect(works.reload.fields.first.is_identifier).to be_falsy

    works.fields.first.update_attributes is_identifier: true
    expect(people.reload.fields.first.is_identifier).to be_truthy
  end

  it "should synchronize storage on entities with the field name attribute" do
    ActiveJob::Base.queue_adapter = :inline
    works.update fields: [
      Field.new(name: 'viaf_id', show_label: 'stack', is_identifier: true)
    ]

    mona_lisa.update dataset: {'viaf_id' => '1234'}
    last_supper.update dataset: {'viaf_id' => '5678'}

    works.fields.first.update name: 'viaf'

    expect(mona_lisa.reload.dataset['viaf']).to eq('1234')
    expect(last_supper.reload.dataset['viaf']).to eq('5678')

    works.fields.first.destroy

    expect(mona_lisa.reload.dataset['viaf']).to be_nil
    expect(last_supper.reload.dataset['viaf']).to be_nil
  end

  it 'should validate mandatory fields' do
    field = described_class.create(
      kind_id: works.id,
      name: 'cycle',
      show_label: 'Cycle',
      mandatory: true
    )

    ml = mona_lisa
    ml.dataset['cycle'] = ''
    field.entity = ml

    expect(field.validate_value).to eq(:empty)

    ml.dataset['cycle'] = ' '
    expect(field.validate_value).to eq(:empty)

    ml.dataset['cycle'] = nil
    expect(field.validate_value).to eq(:empty)

    ml.dataset['cycle'] = 'x'
    expect(field.validate_value).to eq(true)
  end

  it 'should fall back to the show label for other labels'
end

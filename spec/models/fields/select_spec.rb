require 'rails_helper'

RSpec.describe Fields::Select do
  it 'should validate against a list of values' do
    field = described_class.create(
      kind_id: works.id,
      name: 'cycle',
      show_label: 'Cycle',
      subtype: 'select',
      values: ['sun', 'moon']
    )

    ml = mona_lisa
    ml.dataset['cycle'] = 'james'
    field.entity = ml
    expect(field.validate_value).to eq(:invalid)
  end

  it 'should reject blank values when mandatory and when value list is empty' do
    field = described_class.create(
      kind_id: works.id,
      name: 'cycle',
      show_label: 'Cycle',
      subtype: 'select',
      values: ''
    )

    ml = mona_lisa
    ml.dataset['cycle'] = ''
    field.entity = ml
    expect(field.validate_value).to eq(true)

    field.update_column :mandatory, true
    expect(field.validate_value).to eq(:empty)
  end

  it 'should honor the mandatory flag with non-empty value list' do
    field = described_class.create(
      kind_id: works.id,
      name: 'cycle',
      show_label: 'Cycle',
      subtype: 'select',
      values: [nil, '', 'sun'],
      mandatory: true
    )

    ml = mona_lisa
    ml.dataset['cycle'] = ''
    field.entity = ml
    expect(field.validate_value).to eq(:empty)
  end
end

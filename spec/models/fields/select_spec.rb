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
end

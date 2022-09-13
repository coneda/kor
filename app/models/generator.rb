class Generator < ApplicationRecord
  acts_as_list scope: [:kind_id], top_of_list: 0
  default_scope{ order(:position) }

  belongs_to :kind, touch: true

  validates :name,
    presence: true,
    format: {with: /\A[a-z0-9_]+\z/},
    white_space: true

  validates :directive, presence: true

  def self.examples
    {
      'link_if_value_present' => "{{#entity.dataset.wikidata_id}}
<a href=\"https://www.wikidata.org/wiki/{{entity.dataset.wikidata_id}}\">» Wikidata</a>
{{/entity.dataset.wikidata_id}}"
    }
  end
end

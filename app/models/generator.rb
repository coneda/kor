class Generator < ApplicationRecord
  belongs_to :kind, touch: true

  validates :name,
    :presence => true,
    :format => {:with => /\A[a-z0-9_]+\z/},
    :white_space => true

  validates :directive, :presence => true

  def self.examples
    return {
      'link_if_value_present' => "{{#entity.dataset.wikidata_id}}
<a href=\"https://www.wikidata.org/wiki/{{entity.dataset.wikidata_id}}\">» Wikidata</a>
{{/entity.dataset.wikidata_id}}"
    }
  end
end

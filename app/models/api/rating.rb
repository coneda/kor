class Api::Rating < ActiveRecord::Base
  
  self.table_name = 'ratings'
  
  serialize :data
  
  belongs_to :user
  belongs_to :entity
  has_many :engagements, :as => :related
  
  validates_presence_of :user_id, :entity_id, :data, :if => "state == 'done'"
  
  def self.next_entities(namespace, user, kind_id = nil, collection_ids = nil)
    base = Entity.
      select('e.id, count(r.id) AS rc, count(r.user_id) AS ruc').
      from('entities e').
      joins('LEFT JOIN ratings r ON e.id = r.entity_id').
      group('e.id').
      order('rc ASC, ruc ASC')

    base = base.where("e.kind_id = ?", kind_id) if kind_id
    base = base.where("e.collection_id IN (?)", collection_ids) if collection_ids
    
    base
  end
  
  def self.next_entity(namespace)
    self.where(:namespace => namespace, :state => 'open').order('rand()').first
  end
  
  def self.prepare(namespace, kind_id = nil, collection_ids = nil, amount = 5000)
    existing = Api::Rating.where(:namespace => namespace, :state => 'open').count
    next_entities(namespace, nil, kind_id, collection_ids).limit(amount - existing).each do |e|
      Api::Rating.create(
        :state => 'open',
        :entity_id => e.id,
        :namespace => namespace
      )
    end
  end
  
end

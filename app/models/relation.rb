class Relation < ActiveRecord::Base
  serialize :from_kind_ids
  serialize :to_kind_ids

  acts_as_paranoid

  has_many :relationships, :dependent => :destroy
  
  validates :reverse_name,
    :presence => true,
    :white_space => true
  validates :name,
    :presence => true,
    :white_space => true

  after_validation :generate_uuid, :on => :create
  after_save :correct_directed

  def correct_directed
    if name_changed?
      DirectedRelationship.
        where(relation_name: name_was).
        where(relation_id: id).
        update_all(relation_name: name)
    end

    if reverse_name_changed?
      DirectedRelationship.
        where(relation_name: reverse_name_was).
        where(relation_id: id).
        update_all(relation_name: reverse_name)
    end
  end

  def generate_uuid
    self[:uuid] ||= SecureRandom.uuid
  end

  scope :updated_after, lambda {|time| time.present? ? where("updated_at >= ?", time) : all}
  scope :updated_before, lambda {|time| time.present? ? where("updated_at <= ?", time) : all}
  scope :allowed, lambda {|user, policies| all}
  scope :pageit, lambda { |page, per_page|
    page = (page || 1) - 1
    per_page = [(per_page || 30).to_i, Kor.config['app']['max_results_per_request']].min
    limit(per_page).offset(per_page * page)
  }
  default_scope lambda { order(:name) }
  

  ######################### kinds ##############################################

  def from_kind_ids
    unless self[:from_kind_ids]
      self[:from_kind_ids] = []
    end

    self[:from_kind_ids]
  end

  def to_kind_ids
    unless self[:to_kind_ids]
      self[:to_kind_ids] = []
    end

    self[:to_kind_ids]
  end

  def from_kind_ids=(values)
    write_attribute :from_kind_ids, values.collect{|v|v.to_i}
  end

  def to_kind_ids=(values)
    write_attribute :to_kind_ids, values.collect{|v|v.to_i}
  end

  def self.available_relation_names(options = {})
    from_ids = Kor.array_wrap(options[:from_ids] || []).map{|i| i.to_i}
    to_ids = Kor.array_wrap(options[:to_ids] || []).map{|i| i.to_i}

    results = []
    self.all.each do |relation|
      condition = 
        (!from_ids.present? || (from_ids & relation.from_kind_ids).present?) &&
        (!to_ids.present? || (to_ids & relation.to_kind_ids).present?)
      results << relation.name if condition
      condition = 
        (!from_ids.present? || (from_ids & relation.to_kind_ids).present?) &&
        (!to_ids.present? || (to_ids & relation.from_kind_ids).present?)
      results << relation.reverse_name if condition
    end

    results.sort.uniq
  end

  def self.primary_relation_names
    Kor.config['app.gallery.primary_relations'] || []
  end
  
  def self.secondary_relation_names
    Kor.config['app.gallery.secondary_relations'] || []
  end

  def self.reverse_primary_relation_names
    primary_relation_names.map{|rn| reverse_name_for_name(rn)}
  end
  
  def self.reverse_secondary_relation_names
    secondary_relation_names.map{|rn| reverse_name_for_name(rn)}
  end 

  def self.reverse_name_for_name(name)
    result ||= {}
    return result[name] if result[name]
  
    relation = find_by_name( name )
    return (result[name] = relation.reverse_name) if relation

    relation = find_by_reverse_name( name )
    return (result[name] = relation.name) if relation
  end

end

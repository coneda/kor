class Relation < ActiveRecord::Base
  serialize :from_kind_ids
  serialize :to_kind_ids

  acts_as_paranoid

  has_many :relationships, :dependent => :destroy

  has_many :relation_parent_inheritances, class_name: 'RelationInheritance', foreign_key: :child_id, dependent: :destroy
  has_many :relation_child_inheritances, class_name: 'RelationInheritance', foreign_key: :parent_id, dependent: :destroy
  has_many :parents, through: :relation_parent_inheritances
  has_many :children, through: :relation_child_inheritances
  
  validates :reverse_name,
    :presence => true,
    :white_space => true
  validates :name,
    :presence => true,
    :white_space => true

  validate do |relation|
    to_check = relation.parents.to_a
    cycle = false
    while (r = to_check.pop) && !cycle
      if r.id == relation.id
        cycle = true
      else
        to_check += r.parents.to_a
      end
    end

    if cycle
      relation.errors.add :parent_ids, :would_result_in_cycle
    end
  end

  validate do |relation|
    relation.parents.each do |parent|
      size = (parent.from_kind_ids & relation.from_kind_ids).size
      if size < relation.from_kind_ids.size
        relation.errors.add :from_kind_ids, :cannot_restrict_less_than_parent
      end

      size = (parent.to_kind_ids & relation.to_kind_ids).size
      if size < relation.to_kind_ids.size
        relation.errors.add :to_kind_ids, :cannot_restrict_less_than_parent
      end
    end
  end

  after_validation :generate_uuid, :on => :create
  after_save :correct_directed

  def parent_ids
    relation_parent_inheritances.pluck(:parent_id)
  end

  def parent_ids=(values)
    self.parents = Relation.where(id: values).to_a
  end

  def child_ids
    relation_child_inheritances.pluck(:child_id)
  end

  def child_ids=(values)
    self.children = Relation.where(id: values).to_a
  end

  def removable(cache = {})
    child_ids.empty? && relationship_count(cache) == 0
  end

  def relationship_count(cache = {})
    relationships.count
  end

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
    values |= []
    write_attribute :from_kind_ids, values.map{|v|v.to_i}
  end

  def to_kind_ids=(values)
    values |= []
    write_attribute :to_kind_ids, values.map{|v|v.to_i}
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

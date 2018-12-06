class Relation < ApplicationRecord
  acts_as_paranoid

  has_many :relationships, :dependent => :destroy

  has_many :relation_parent_inheritances, class_name: 'RelationInheritance', foreign_key: :child_id, dependent: :destroy
  has_many :relation_child_inheritances, class_name: 'RelationInheritance', foreign_key: :parent_id, dependent: :destroy
  has_many :parents, through: :relation_parent_inheritances
  has_many :children, through: :relation_child_inheritances
  belongs_to :from_kind, class_name: "Kind"
  belongs_to :to_kind, class_name: "Kind"
  
  validates :reverse_name,
    :presence => true,
    :white_space => true
  validates :name,
    :presence => true,
    :white_space => true
  validates :from_kind_id, :to_kind_id,
    :presence => true

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
    # collection possible endpoints from all parents
    required_from_ids = nil
    required_to_ids = nil
    relation.parents.each do |parent|
      from_ids = [parent.from_kind_id] + parent.from_kind.deep_child_ids
      required_from_ids ||= from_ids
      required_from_ids &= from_ids
      to_ids = [parent.to_kind_id] + parent.to_kind.deep_child_ids
      required_to_ids ||= to_ids
      required_to_ids &= to_ids
    end

    if required_from_ids.is_a?(Array)
      enabled_from_ids = [relation.from_kind_id] + relation.from_kind.deep_child_ids
      # puts 'fROM'
      # p required_from_ids
      # p enabled_from_ids
      subset = ((required_from_ids & enabled_from_ids).size == enabled_from_ids.size)
      unless subset
        relation.errors.add :from_kind_id, :cannot_restrict_less_than_parent
      end
    end

    if required_to_ids.is_a?(Array)
      enabled_to_ids = [relation.to_kind_id] + relation.to_kind.deep_child_ids
      # puts 'TO'
      # p required_to_ids
      # p enabled_to_ids
      subset = ((required_to_ids & enabled_to_ids).size == enabled_to_ids.size)
      unless subset
        relation.errors.add :to_kind_id, :cannot_restrict_less_than_parent
      end
    end
  end

  after_validation :generate_uuid, on: :create
  after_save :correct_directed

  def schema=(value)
    self[:schema] = value.presence
  end

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
        where(is_reverse: false).
        where(relation_id: id).
        update_all(relation_name: name)
    end

    if reverse_name_changed?
      DirectedRelationship.
        where(is_reverse: true).
        where(relation_id: id).
        update_all(relation_name: reverse_name)
    end
  end

  def generate_uuid
    self[:uuid] ||= SecureRandom.uuid
  end

  scope :updated_after, lambda { |time| time.present? ? where("updated_at >= ?", time) : all }
  scope :updated_before, lambda { |time| time.present? ? where("updated_at <= ?", time) : all }
  scope :allowed, lambda { |user, policies| all }
  scope :by_from, lambda { |ids|
    if ids.blank?
      all
    else
      ids = [ids] unless ids.is_a?(Array)
      where(from_kind_id: ids.map { |i| i.to_i })
    end
  }
  scope :by_to, lambda { |ids|
    if ids.blank?
      all
    else
      ids = [ids] unless ids.is_a?(Array)
      where(to_kind_id: ids.map { |i| i.to_i })
    end
  }
  default_scope lambda { order(:name) }
  
  def self.available_relation_names(options = {})
    froms = options[:from_ids].presence || []
    tos = options[:to_ids].presence || []
    froms = Array.wrap(froms).map { |e| e.to_i }.uniq
    tos = Array.wrap(tos).map { |e| e.to_i }.uniq

    names = {}

    Relation.all.each do |relation|
      names[relation.name] ||= { froms: [], tos: [] }
      names[relation.name][:froms] << relation.from_kind_id
      names[relation.name][:tos] << relation.to_kind_id

      names[relation.reverse_name] ||= { froms: [], tos: [] }
      names[relation.reverse_name][:froms] << relation.to_kind_id
      names[relation.reverse_name][:tos] << relation.from_kind_id
    end

    names.each do |k, v|
      if froms.present? && (froms & v[:froms]).size < froms.size
        names.delete k
      end

      if tos.present? && (tos & v[:tos]).size < tos.size
        names.delete k
      end
    end

    names.keys.sort.uniq
  end

  def self.primary_relation_names
    Kor.settings['primary_relations'] || []
  end
  
  def self.secondary_relation_names
    Kor.settings['secondary_relations'] || []
  end

  def self.reverse_primary_relation_names
    primary_relation_names.map { |rn| reverse_name_for_name(rn) }
  end
  
  def self.reverse_secondary_relation_names
    secondary_relation_names.map { |rn| reverse_name_for_name(rn) }
  end 

  def self.reverse_name_for_name(name)
    result ||= {}
    return result[name] if result[name]
  
    relation = find_by_name(name)
    return (result[name] = relation.reverse_name) if relation

    relation = find_by_reverse_name(name)
    return (result[name] = relation.name) if relation
  end

  def self.to_entity_kind_ids(relation_name)
    kind_ids = where(name: relation_name).map { |r| r.to_kind_id }
    kind_ids << where(reverse_name: relation_name).map { |r| r.from_kind_id }
    kind_ids.flatten.uniq
  end

  def invert!
    self.class.transaction do
      self.update_columns(
        name: self.reverse_name,
        reverse_name: self.name,
        from_kind_id: self.to_kind_id,
        to_kind_id: self.from_kind_id
      )
      self.class.connection.execute(
        [
          'UPDATE relationships r1, relationships r2',
          'SET',
            'r1.from_id = r2.to_id,',
            'r1.to_id = r2.from_id,',
            'r1.normal_id = r2.reversal_id,',
            'r1.reversal_id = r2.normal_id',
          "WHERE r1.id = r2.id AND r2.relation_id = #{self.id}"
        ].join(' ')
      )
      # we don't need to swap to_id and from_id on directed relationships
      # because that would be reverting swapping normal and reverse on the
      # relationship
      self.class.connection.execute(
        [
          'UPDATE directed_relationships r1, directed_relationships r2',
          'SET r1.is_reverse = NOT r2.is_reverse',
          "WHERE r1.id = r2.id AND r1.relation_id = #{self.id}"
        ].join(' ')
      )
    end
  end

  def matches_kinds?(other)
    from_kind_id == other.from_kind_id && to_kind_id == other.to_kind_id
  end

  def can_merge?(others)
    others = [others] unless others.is_a?(Array)
    others.all? do |other|
      self != other && matches_kinds?(other)
    end
  end

  def merge!(others)
    others = [others] unless others.is_a?(Array)
    return false unless can_merge?(others)

    self.class.transaction do
      others.each do |other|
        Relationship.where(relation_id: other.id).update_all(
          relation_id: self.id
        )
        DirectedRelationship.where(
          relation_id: other.id,
          is_reverse: false
        ).update_all(
          relation_id: self.id,
          relation_name: self.name
        )
        DirectedRelationship.where(
          relation_id: other.id,
          is_reverse: true
        ).update_all(
          relation_id: self.id,
          relation_name: self.reverse_name
        )
        other.destroy
      end
    end

    self
  end
end

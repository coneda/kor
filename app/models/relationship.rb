class Relationship < ActiveRecord::Base
  serialize :properties
  
  belongs_to :owner, :class_name => "User"
  belongs_to :relation
  belongs_to :from, :class_name => "Entity", :foreign_key => :from_id
  belongs_to :to, :class_name => "Entity", :foreign_key => :to_id

  belongs_to :natural, :class_name => "DirectedRelationship", :dependent => :destroy
  belongs_to :reversal, :class_name => "DirectedRelationship", :dependent => :destroy

  after_validation do |relationship|
    relationship.properties = relationship.properties.uniq
    relationship.ensure_directed
  end

  def ensure_directed
    self.natural ||= DirectedRelationship.new
    self.reversal ||= DirectedRelationship.new

    # self.natural.save
    # self.reverse.save

    

    self.reversal.update_attributes(
      :from_id => self.to_id,
      :to_id => self.from_id,
      :relation_id => self.relation_id,
      :reverse => true
    )

    self.natural.update_attributes(
      :from_id => self.from_id,
      :to_id => self.to_id,
      :relation_id => self.relation_id,
      :reverse => false
    )
  end

  def other_entity(entity)
    from_id == entity.id ? to : from
  end

  def relation_name_for_entity(entity)
    if from_id == entity.id
      relation.name
    elsif to_id == entity.id
      relation.reverse_name
    else
      raise "entity not part of relationship"
    end
  end

  def to_entity_for_relation_name(relation_name)
    if relation.name == relation_name
      to
    elsif relation.reverse_name == relation_name
      from
    else
      raise "relation name not part of relationship"
    end
  end

  def from_entity_for_relation_name(relation_name)
    if relation.name == relation_name
      from
    elsif relation.reverse_name == relation_name
      to
    else
      raise "relation name not part of relationship"
    end
  end

  def self.find_by_participants_and_relation_name(options = {})
    conditions = Array.new
    reverse_conditions = Array.new
    values = Array.new
    reverse_values = Array.new

    if options[:relation_name]
      relations = Array(options[:relation_name])

      conditions << "relations.name IN (?)"
      values << relations
      reverse_conditions << "relations.reverse_name IN (?)"
      reverse_values << relations
    end
    
    if options[:from_id]
      ids = Array(Kor.id_for_model(options[:from_id]))

      conditions << "relationships.from_id IN (?)"
      values << ids
      reverse_conditions << "relationships.to_id IN (?)"
      reverse_values << ids
    end

    if options[:to_id]
      ids = Array(Kor.id_for_model(options[:to_id]))

      conditions << "relationships.to_id IN (?)"
      values << ids
      reverse_conditions << "relationships.from_id IN (?)"
      reverse_values << ids
    end

    conditions = "(#{conditions.join(') AND (')})"
    reverse_conditions = "(#{reverse_conditions.join(') AND (')})"
    conditions = [ "#{conditions} OR #{reverse_conditions}" ] + values + reverse_values
    joins(:relation).where(conditions).includes(:from, :to)
  end

  def self.related?(from_id, relation_name, to_id)
    !find_by_participants_and_relation_name(
      :from_id => from_id,
      :relation_name => relation_name,
      :to_id => to_id).empty?
  end

  def self.relate_once_and_save(from_id, relation_name, to_id, properties = [])
    unless related?(from_id, relation_name, to_id)
      relate_and_save(from_id, relation_name, to_id, properties)
    end
  end

  def self.relate_and_save( from_id, relation_name, to_id, properties = [] )
    r = relate(from_id, relation_name, to_id, properties)
    r.save
    r
  end

  def self.relate(from_id, relation_name, to_id, properties = [])
    from_id = Kor.id_for_model(from_id)
    to_id = Kor.id_for_model(to_id)

    Relationship.new(
      :from_id => from_id,
      :relation_name => relation_name,
      :to_id => to_id,
      :properties => properties
    )
  end
  
  validates_presence_of :from_id, :to_id, :relation_id, :message => 'can_not_be_empty'
  
  after_validation(:on => :create) do |model|
    model.uuid = SecureRandom.uuid
  end
  
  
  ########################## properties ########################################

  def has_properties?
    !properties.blank?
  end
  
  def properties
    read_attribute(:properties) || []
  end

  
  ########################## relation related ##################################
  attr_writer :reverse

  def has_relation_name(name)
    relation.has_name(name)
  end

  def reverse
    @reverse ||= false
  end

  # this method only exists because the writer is used in the relationship form
  def relation_name
    relation.name if relation
  end
  
  def relation_name=(value)
    if ( r = Relation.find_by_name(value) )
      self.reverse = false
      self[:relation_id] = r.id
    elsif ( r = Relation.find_by_reverse_name(value) )
      self.reverse = true
      self[:relation_id] = r.id
      swap_to_and_from
    else
      raise "the relation '#{value}' does not exist"
    end
  end

  def swap_to_and_from
    tmp = read_attribute :from_id
    write_attribute :from_id, read_attribute(:to_id)
    write_attribute :to_id, tmp
  end

  ########################## entity related ####################################

  def from_id=(id)
    if reverse
      self[:to_id] = id
    else
      self[:from_id] = id
    end
  end

  def to_id=(id)
    if reverse
      self[:from_id] = id
    else
      self[:to_id] = id
    end
  end

  def human
    from_name = from.display_name.first(30)
    to_name = to.display_name.first(30)
    relation_name = (reverse ? relation.reverse_name : relation.name)
    r = (reverse ? 'reverse' : 'normal')
    "'#{from_name}' [#{r}] #{relation_name} '#{to_name}'"
  end
  
end

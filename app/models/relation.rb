class Relation < ActiveRecord::Base
  serialize :from_kind_ids
  serialize :to_kind_ids

  has_many :relationships, :dependent => :destroy
  
  validates :reverse_name,
    :presence => true,
    :white_space => true
  validates :name,
    :presence => true,
    :white_space => true

  after_validation :on => :create do |model|
    model.generate_uuid
  end
  def generate_uuid
    write_attribute(:uuid, UUIDTools::UUID.random_create.to_s)
  end

  default_scope order(:name)
  

  ######################### kinds ##############################################

  def from_kind_ids
    self[:from_kind_ids] ||= []
  end

  def to_kind_ids
    self[:to_kind_ids] ||= []
  end

  def from_kind_ids=(values)
    write_attribute :from_kind_ids, values.collect{|v|v.to_i}
  end

  def to_kind_ids=(values)
    write_attribute :to_kind_ids, values.collect{|v|v.to_i}
  end
  
  def self.available_relation_names_for_kinds(from_kind_ids)
    if from_kind_ids && !from_kind_ids.blank?
      names = Array(from_kind_ids).map{|id| available_relation_names(id)}

      result = names
      
      unless result.empty?
        result = names.first
        names.each do |n|
          result &= n
        end
      end
      
      result.sort
    else
      available_relation_names
    end
  end
  
  def self.available_relation_names(from_kind_id = nil, to_kind_id = nil)
    if from_kind_id == '-1' 
      from_kind_id = nil
    elsif from_kind_id.is_a? String
      from_kind_id = from_kind_id.to_i
    end
    
    if to_kind_id == '-1' 
      to_kind_id = nil
    elsif to_kind_id.is_a? String
      to_kind_id = to_kind_id.to_i
    end
  
    results = []
    all.each do |r|
      from_include_from = (r.from_kind_ids.include?(from_kind_id) or ! from_kind_id)
      to_include_to = (r.to_kind_ids.include?(to_kind_id) or ! to_kind_id)
      results << r.name if from_include_from and to_include_to

      from_include_to = (r.from_kind_ids.include?(to_kind_id) or ! to_kind_id)
      to_include_from = (r.to_kind_ids.include?(from_kind_id) or ! from_kind_id)
      results << r.reverse_name if from_include_to and to_include_from
    end
    results.sort.uniq
  end
  

  ######################### other ##############################################
  # TODO This should also work with an array in the configfile
  def has_name(name)
    self.name == name or reverse_name == name
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

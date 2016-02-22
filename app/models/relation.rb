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
    per_page = [(per_page || 30).to_i, 500].min
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

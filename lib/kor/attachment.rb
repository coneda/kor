class Kor::Attachment
  
  def initialize(entity)
    raise "can't create dataset for entity without a kind: #{entity.inspect}" unless entity.kind
  
    @entity = entity
    
    retrieve if !new_record? && id
  end
  
  
  # finders
  
  def self.find_by_synonym(pattern)
    find :synonyms => Regexp.new(pattern, Regexp::IGNORECASE)
  end
  
  def self.find_by_property(pattern)
    results = find :properties => {'$elemMatch' => {:name => Regexp.new(pattern, Regexp::IGNORECASE)}}
    results += find :properties => {'$elemMatch' => {:value => Regexp.new(pattern, Regexp::IGNORECASE)}}
    results.uniq
  end
  
  def self.find(params, rerun = true)
    result = collection.find(params)
    result.to_a.map{|e| e['entity_id']}
  rescue Mongo::ConnectionFailure => e
    if rerun
      find params, false 
    else
      raise e
    end
  end
  
  
  # Accessors
  
  attr_reader :entity, :document
  
  def new_record?
    @entity.new_record? || !id
  end
  
  def id
    @id ||= @entity.attachment_id
  end
  
  def entity_id
    document['entity_id']
  end
  
  def entity_id=(value)
    document['entity_id'] = value
  end
  
  
  # Keystore
  
  def document
    @document ||= {}
  end
  
  def dataset
    document['dataset'] || {}
  end
  
  def properties
    document['properties'] || {}
  end
  
  
  # Schema
  
  def schema
    entity.kind.field_instances(entity)
  end
  
  def render_field(name, value)
    renderer = schema.find{|f| f.name == name}
    renderer ? renderer.render(value) : ""
  end
  
  def defines_schema?
    !entity.kind.fields.empty?
  end
  
  
  # Validation
  
  def validate
    (document['properties'] || []).each do |property|
      @entity.errors.add :properties, :needs_label if property['label'].blank?
      @entity.errors.add :properties, :needs_value if property['value'].blank?
    end
    
    validate_dataset
  end
  
  def validate_dataset
    dataset.each do |name, value|
      handler = schema.find{|f| f.name == name}
      puts name unless handler
      puts value unless handler
      handler.validate_value
    end
  end
  
  
  # Persistence
  
  def retrieve(rerun = true)
    if id
      @document = self.class.collection.find('_id' => BSON::ObjectId.from_string(id)).first || {}
      @document.delete('_id')
    else
      raise "cannot read mongo document without an id"
    end
  rescue Mongo::ConnectionFailure => e
    if rerun
      retrieve false 
    else
      raise e
    end
  end
  
  def create(rerun = true)
    @id = self.class.collection.insert(document).to_s
    @entity.attachment_id = @id
  rescue Mongo::ConnectionFailure => e
    if rerun
      create false 
    else
      raise e
    end
  end
  
  def update(rerun = true)
    self.class.collection.update({'_id' => BSON::ObjectId.from_string(id)}, document)
  rescue Mongo::ConnectionFailure => e
    if rerun
      update false 
    else
      raise e
    end
  end
  
  def destroy(rerun = true)
    self.class.collection.remove('_id' => BSON::ObjectId.from_string(id))
  rescue Mongo::ConnectionFailure => e
    if rerun
      destroy false 
    else
      raise e
    end
  end
  
  def save
    if new_record?
      create
    else
      update
    end
  end
  
  
  # Configuration
  
  def self.config
    @@config ||= YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]['mongo'].reverse_merge(
      'host' => '127.0.0.1',
      'port' => 27017
    )
  end
  
  def self.connection(reconnect = false)
    @@connection ||= Mongo::Connection.new(config['host'], config['port'])
  end
  
  def self.db
    @@db ||= connection.db(config['database'])
  end
  
  def self.collection
    @@collection ||= db['attachments']
  end
  
end

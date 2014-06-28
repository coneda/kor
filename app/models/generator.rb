class Generator < ActiveRecord::Base
  
  # Associations
  
  belongs_to :kind
  
  
  # Validations
  
  validates_presence_of :name, :directive
  validates_format_of :name, :with => /^[a-z0-9_]+$/
  
  
  # Scopes
  
  scope :only_attributes, where(:is_attribute => true)
  
  
  # Entity processing
  
  def to_html(entity)
    @current_html = directive
    
    replace('id'){ entity.id }
    replace('uuid'){ entity.uuid }
    replace('name'){ entity.name }
    replace('collection_id'){ entity.collection_id }
    replace('fields:[a-z0-9_]+') do |match|
      field_name = match.gsub /fields:/, ''
      field = entity.attachment.schema.where(:name => field_name).first
      field.attachment = entity.attachment
      field.value
    end
    
    @current_html
  end
  
  def replace(pattern)
    failed = false
  
    @current_html.scan(/\{kor:(#{pattern})\}/).each do |match|
      match = match.first
      
      value = begin
        yield(match)
      rescue => e
        nil
      end
      
      if value.blank?
        @current_html = ""
      else
        @current_html.gsub! /\{kor:(#{match})\}/, value.to_s
      end
    end
  end
  
end

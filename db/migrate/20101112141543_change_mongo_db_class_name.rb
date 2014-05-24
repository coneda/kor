class ChangeMongoDbClassName < ActiveRecord::Migration

  def self.old_name
    "Kor::Mongo::Attachment::Config"
  end
  
  def self.new_name
    "Kor::Attachment::MongoDb"
  end

  def self.up
    execute "UPDATE kinds SET attachment_class = '#{new_name}' WHERE attachment_class LIKE '#{old_name}'"
  end

  def self.down
    execute "UPDATE kinds SET attachment_class = '#{old_name}' WHERE attachment_class LIKE '#{new_name}'"
  end
  
end

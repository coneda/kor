# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140914112118) do

  create_table "authority_group_categories", :force => true do |t|
    t.integer  "lock_version"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authority_group_categories", ["lft", "rgt", "parent_id"], :name => "agc_hierarchy_index"

  create_table "authority_groups", :force => true do |t|
    t.integer  "lock_version"
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authority_group_category_id"
  end

  add_index "authority_groups", ["authority_group_category_id"], :name => "index_authority_groups_on_authority_group_category_id"

  create_table "authority_groups_entities", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "authority_group_id"
  end

  add_index "authority_groups_entities", ["authority_group_id"], :name => "index_authority_groups_entities_on_authority_group_id"
  add_index "authority_groups_entities", ["entity_id"], :name => "index_authority_groups_entities_on_entity_id"

  create_table "collections", :force => true do |t|
    t.integer  "lock_version"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections_credentials", :force => true do |t|
    t.integer "collection_id"
    t.integer "credential_id"
    t.string  "policy"
  end

  add_index "collections_credentials", ["collection_id", "credential_id", "policy"], :name => "master"

  create_table "credentials", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "lock_version", :default => 0
  end

  add_index "credentials", ["name"], :name => "index_credentials_on_name"

  create_table "credentials_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "credential_id"
  end

  add_index "credentials_users", ["credential_id"], :name => "index_credentials_users_on_credential_id"
  add_index "credentials_users", ["user_id", "credential_id"], :name => "index_credentials_users_on_user_id_and_credential_id", :unique => true
  add_index "credentials_users", ["user_id"], :name => "index_credentials_users_on_user_id"

  create_table "dataset_artworks", :force => true do |t|
    t.string  "dimensions"
    t.integer "lock_version",       :default => 0
    t.string  "material_technique"
  end

  create_table "dataset_images", :force => true do |t|
    t.string  "uri"
    t.string  "datahash"
    t.string  "file_format"
    t.integer "width"
    t.integer "height"
    t.integer "bytes"
    t.integer "lock_version", :default => 0
  end

  create_table "dataset_literatures", :force => true do |t|
    t.string  "isbn"
    t.string  "year_of_publication"
    t.string  "edition"
    t.string  "publisher"
    t.integer "lock_version",        :default => 0
  end

  create_table "dataset_textuals", :force => true do |t|
    t.integer "lock_version"
    t.text    "text"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "downloads", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "file_name"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "downloads", ["uuid"], :name => "index_downloads_on_uuid"

  create_table "engagements", :force => true do |t|
    t.integer  "user_id"
    t.string   "kind"
    t.string   "related_type"
    t.integer  "related_id"
    t.integer  "credits"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "engagements", ["user_id", "kind", "related_type", "related_id"], :name => "lookup"

  create_table "entities", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "distinct_name"
    t.text     "comment"
    t.integer  "kind_id"
    t.integer  "collection_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",        :default => 0
    t.string   "no_name_statement"
    t.integer  "updater_id"
    t.string   "subtype"
    t.text     "external_references"
    t.boolean  "approved"
    t.string   "attachment_id"
    t.integer  "medium_id"
  end

  add_index "entities", ["created_at"], :name => "index_entities_on_created_at"
  add_index "entities", ["creator_id"], :name => "index_entities_on_user_id"
  add_index "entities", ["distinct_name"], :name => "index_entities_on_distinct_name"
  add_index "entities", ["kind_id"], :name => "index_entities_on_kind_id"
  add_index "entities", ["medium_id"], :name => "mediy"
  add_index "entities", ["name"], :name => "index_entities_on_name"
  add_index "entities", ["uuid"], :name => "index_entities_on_uuid"

  create_table "entities_system_groups", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "system_group_id"
  end

  add_index "entities_system_groups", ["entity_id"], :name => "index_entities_system_groups_on_entity_id"
  add_index "entities_system_groups", ["system_group_id"], :name => "index_entities_system_groups_on_system_group_id"

  create_table "entities_tags", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "tag_id"
  end

  add_index "entities_tags", ["entity_id", "tag_id"], :name => "index_entities_tags_on_entity_id_and_tag_id", :unique => true

  create_table "entities_user_groups", :id => false, :force => true do |t|
    t.integer "entity_id"
    t.integer "user_group_id"
  end

  add_index "entities_user_groups", ["entity_id"], :name => "index_entities_user_groups_on_entity_id"
  add_index "entities_user_groups", ["user_group_id"], :name => "index_entities_user_groups_on_user_group_id"

  create_table "entity_datings", :force => true do |t|
    t.integer "lock_version"
    t.integer "entity_id"
    t.string  "label"
    t.string  "dating_string"
    t.integer "from_day"
    t.integer "to_day"
  end

  add_index "entity_datings", ["entity_id"], :name => "index_entity_datings_on_entity_id"

  create_table "exception_logs", :force => true do |t|
    t.string   "kind"
    t.string   "message"
    t.text     "backtrace"
    t.datetime "created_at"
    t.string   "uri"
    t.text     "params"
  end

  create_table "fields", :force => true do |t|
    t.integer  "kind_id"
    t.string   "type"
    t.string   "name"
    t.string   "show_label"
    t.string   "form_label"
    t.string   "search_label"
    t.text     "settings"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "generators", :force => true do |t|
    t.integer  "kind_id"
    t.boolean  "is_attribute"
    t.string   "name"
    t.string   "show_label"
    t.text     "directive"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "kinds", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "description"
    t.text     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
    t.string   "plural_name"
  end

  create_table "media", :force => true do |t|
    t.integer "lock_version"
    t.string  "image_file_name"
    t.string  "image_content_type"
    t.integer "image_file_size"
    t.integer "image_updated_at"
    t.string  "document_file_name"
    t.string  "document_content_type"
    t.integer "document_file_size"
    t.integer "document_updated_at"
    t.string  "datahash"
    t.string  "original_url"
    t.boolean "cache"
    t.string  "state"
    t.boolean "document_processing"
    t.boolean "image_processing"
  end

  create_table "properties", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "reference_id"
    t.string   "label"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  add_index "properties", ["entity_id"], :name => "index_properties_on_entity_id"
  add_index "properties", ["label"], :name => "index_properties_on_name"
  add_index "properties", ["value"], :name => "index_properties_on_value"

  create_table "publishments", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "name"
    t.datetime "valid_until"
    t.integer  "user_group_id"
  end

  add_index "publishments", ["user_id"], :name => "index_publishments_on_user_id"

  create_table "ratings", :force => true do |t|
    t.string   "namespace"
    t.integer  "user_id"
    t.integer  "entity_id"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "state"
  end

  add_index "ratings", ["entity_id", "state"], :name => "index_ratings_on_entity_id_and_state"

  create_table "relations", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "reverse_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  :default => 0
    t.text     "from_kind_ids"
    t.text     "to_kind_ids"
    t.string   "description"
  end

  add_index "relations", ["name"], :name => "index_relations_on_name"
  add_index "relations", ["reverse_name"], :name => "index_relations_on_reverse_name"

  create_table "relationships", :force => true do |t|
    t.string   "uuid"
    t.integer  "owner_id"
    t.integer  "relation_id"
    t.integer  "from_id"
    t.integer  "to_id"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  add_index "relationships", ["from_id"], :name => "index_relationships_on_from_id"
  add_index "relationships", ["relation_id", "from_id", "to_id"], :name => "index_relationships_on_relation_id_and_from_id_and_to_id"
  add_index "relationships", ["relation_id"], :name => "index_relationships_on_relation_id"
  add_index "relationships", ["to_id"], :name => "index_relationships_on_to_id"
  add_index "relationships", ["uuid"], :name => "index_relationships_on_uuid"

  create_table "searches", :force => true do |t|
    t.integer  "user_id"
    t.string   "search_type"
    t.integer  "collection_id"
    t.integer  "kind_id"
    t.string   "name"
    t.string   "dating"
    t.string   "properties"
    t.text     "dataset"
    t.text     "relationships"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "synonyms", :force => true do |t|
    t.integer "entity_id"
    t.string  "name"
    t.integer "lock_version", :default => 0
  end

  add_index "synonyms", ["entity_id"], :name => "index_synonyms_on_entity_id"
  add_index "synonyms", ["name"], :name => "index_synonyms_on_name"

  create_table "system_groups", :force => true do |t|
    t.integer  "lock_version"
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_groups", :force => true do |t|
    t.integer  "lock_version"
    t.integer  "user_id"
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_groups", ["user_id"], :name => "index_user_groups_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "full_name"
    t.string   "name"
    t.string   "email"
    t.datetime "last_login"
    t.boolean  "active"
    t.string   "password"
    t.string   "activation_hash"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",          :default => 0
    t.datetime "expires_at"
    t.boolean  "terms_accepted",        :default => false
    t.string   "login_attempts"
    t.boolean  "relation_admin"
    t.boolean  "authority_group_admin"
    t.boolean  "user_admin"
    t.boolean  "collection_admin"
    t.boolean  "kind_admin"
    t.boolean  "developer"
    t.boolean  "credential_admin"
    t.boolean  "admin"
    t.integer  "default_collection_id"
    t.string   "home_page"
    t.integer  "collection_id"
    t.integer  "credential_id"
    t.boolean  "rating_admin"
    t.string   "api_key"
    t.string   "parent_username"
  end

  add_index "users", ["name"], :name => "index_users_on_name", :unique => true
  add_index "users", ["parent_username"], :name => "index_users_on_parent_username"

end

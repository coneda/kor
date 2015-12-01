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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151111112819) do

  create_table "authority_group_categories", force: :cascade do |t|
    t.integer  "lock_version", limit: 4
    t.integer  "parent_id",    limit: 4
    t.integer  "lft",          limit: 4
    t.integer  "rgt",          limit: 4
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authority_group_categories", ["lft", "rgt", "parent_id"], name: "agc_hierarchy_index", using: :btree

  create_table "authority_groups", force: :cascade do |t|
    t.integer  "lock_version",                limit: 4
    t.string   "name",                        limit: 255
    t.string   "uuid",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authority_group_category_id", limit: 4
  end

  add_index "authority_groups", ["authority_group_category_id"], name: "index_authority_groups_on_authority_group_category_id", using: :btree

  create_table "authority_groups_entities", id: false, force: :cascade do |t|
    t.integer "entity_id",          limit: 4
    t.integer "authority_group_id", limit: 4
  end

  add_index "authority_groups_entities", ["authority_group_id"], name: "index_authority_groups_entities_on_authority_group_id", using: :btree
  add_index "authority_groups_entities", ["entity_id"], name: "index_authority_groups_entities_on_entity_id", using: :btree

  create_table "collections", force: :cascade do |t|
    t.integer  "lock_version", limit: 4
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections_credentials", force: :cascade do |t|
    t.integer "collection_id", limit: 4
    t.integer "credential_id", limit: 4
    t.string  "policy",        limit: 255
  end

  add_index "collections_credentials", ["collection_id", "credential_id", "policy"], name: "master", using: :btree

  create_table "credentials", force: :cascade do |t|
    t.string  "name",         limit: 255
    t.string  "description",  limit: 255
    t.integer "lock_version", limit: 4,   default: 0
  end

  add_index "credentials", ["name"], name: "index_credentials_on_name", using: :btree

  create_table "credentials_users", id: false, force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.integer "credential_id", limit: 4
  end

  add_index "credentials_users", ["credential_id"], name: "index_credentials_users_on_credential_id", using: :btree
  add_index "credentials_users", ["user_id", "credential_id"], name: "index_credentials_users_on_user_id_and_credential_id", unique: true, using: :btree
  add_index "credentials_users", ["user_id"], name: "index_credentials_users_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "downloads", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "uuid",         limit: 255
    t.string   "file_name",    limit: 255
    t.string   "content_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "downloads", ["uuid"], name: "index_downloads_on_uuid", using: :btree

  create_table "entities", force: :cascade do |t|
    t.string   "uuid",              limit: 255
    t.string   "name",              limit: 255
    t.string   "distinct_name",     limit: 255
    t.text     "comment",           limit: 65535
    t.integer  "kind_id",           limit: 4
    t.integer  "collection_id",     limit: 4
    t.integer  "creator_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",      limit: 4,     default: 0
    t.string   "no_name_statement", limit: 255
    t.integer  "updater_id",        limit: 4
    t.string   "subtype",           limit: 255
    t.boolean  "approved"
    t.integer  "medium_id",         limit: 4
    t.text     "attachment",        limit: 65535
  end

  add_index "entities", ["collection_id", "kind_id"], name: "collections_kinds", using: :btree
  add_index "entities", ["created_at"], name: "index_entities_on_created_at", using: :btree
  add_index "entities", ["creator_id"], name: "index_entities_on_user_id", using: :btree
  add_index "entities", ["distinct_name"], name: "index_entities_on_distinct_name", using: :btree
  add_index "entities", ["name"], name: "index_entities_on_name", using: :btree
  add_index "entities", ["uuid"], name: "index_entities_on_uuid", using: :btree

  create_table "entities_system_groups", id: false, force: :cascade do |t|
    t.integer "entity_id",       limit: 4
    t.integer "system_group_id", limit: 4
  end

  add_index "entities_system_groups", ["entity_id"], name: "index_entities_system_groups_on_entity_id", using: :btree
  add_index "entities_system_groups", ["system_group_id"], name: "index_entities_system_groups_on_system_group_id", using: :btree

  create_table "entities_tags", id: false, force: :cascade do |t|
    t.integer "entity_id", limit: 4
    t.integer "tag_id",    limit: 4
  end

  add_index "entities_tags", ["entity_id", "tag_id"], name: "index_entities_tags_on_entity_id_and_tag_id", unique: true, using: :btree

  create_table "entities_user_groups", id: false, force: :cascade do |t|
    t.integer "entity_id",     limit: 4
    t.integer "user_group_id", limit: 4
  end

  add_index "entities_user_groups", ["entity_id"], name: "index_entities_user_groups_on_entity_id", using: :btree
  add_index "entities_user_groups", ["user_group_id"], name: "index_entities_user_groups_on_user_group_id", using: :btree

  create_table "entity_datings", force: :cascade do |t|
    t.integer "lock_version",  limit: 4
    t.integer "entity_id",     limit: 4
    t.string  "label",         limit: 255
    t.string  "dating_string", limit: 255
    t.integer "from_day",      limit: 4
    t.integer "to_day",        limit: 4
  end

  add_index "entity_datings", ["entity_id"], name: "index_entity_datings_on_entity_id", using: :btree

  create_table "exception_logs", force: :cascade do |t|
    t.string   "kind",       limit: 255
    t.string   "message",    limit: 255
    t.text     "backtrace",  limit: 65535
    t.datetime "created_at"
    t.string   "uri",        limit: 255
    t.text     "params",     limit: 65535
  end

  create_table "fields", force: :cascade do |t|
    t.integer  "kind_id",      limit: 4
    t.string   "type",         limit: 255
    t.string   "name",         limit: 255
    t.string   "show_label",   limit: 255
    t.string   "form_label",   limit: 255
    t.string   "search_label", limit: 255
    t.text     "settings",     limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "generators", force: :cascade do |t|
    t.integer  "kind_id",    limit: 4
    t.string   "name",       limit: 255
    t.text     "directive",  limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "kinds", force: :cascade do |t|
    t.string   "uuid",         limit: 255
    t.string   "name",         limit: 255
    t.string   "description",  limit: 255
    t.text     "settings",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", limit: 4,     default: 0
    t.string   "plural_name",  limit: 255
  end

  create_table "media", force: :cascade do |t|
    t.integer "lock_version",          limit: 4
    t.string  "image_file_name",       limit: 255
    t.string  "image_content_type",    limit: 255
    t.integer "image_file_size",       limit: 4
    t.integer "image_updated_at",      limit: 4
    t.string  "document_file_name",    limit: 255
    t.string  "document_content_type", limit: 255
    t.integer "document_file_size",    limit: 4
    t.integer "document_updated_at",   limit: 4
    t.string  "datahash",              limit: 255
    t.string  "original_url",          limit: 255
    t.boolean "cache"
    t.string  "state",                 limit: 255
    t.boolean "document_processing"
    t.boolean "image_processing"
  end

  create_table "publishments", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "uuid",          limit: 255
    t.string   "name",          limit: 255
    t.datetime "valid_until"
    t.integer  "user_group_id", limit: 4
  end

  add_index "publishments", ["user_id"], name: "index_publishments_on_user_id", using: :btree

  create_table "relations", force: :cascade do |t|
    t.string   "uuid",          limit: 255
    t.string   "name",          limit: 255
    t.string   "reverse_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",  limit: 4,     default: 0
    t.text     "from_kind_ids", limit: 65535
    t.text     "to_kind_ids",   limit: 65535
    t.string   "description",   limit: 255
  end

  add_index "relations", ["name"], name: "index_relations_on_name", using: :btree
  add_index "relations", ["reverse_name"], name: "index_relations_on_reverse_name", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "uuid",         limit: 255
    t.integer  "owner_id",     limit: 4
    t.integer  "relation_id",  limit: 4
    t.integer  "from_id",      limit: 4
    t.integer  "to_id",        limit: 4
    t.text     "properties",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", limit: 4,     default: 0
  end

  add_index "relationships", ["from_id"], name: "index_relationships_on_from_id", using: :btree
  add_index "relationships", ["relation_id", "from_id", "to_id"], name: "index_relationships_on_relation_id_and_from_id_and_to_id", using: :btree
  add_index "relationships", ["relation_id"], name: "index_relationships_on_relation_id", using: :btree
  add_index "relationships", ["to_id"], name: "index_relationships_on_to_id", using: :btree
  add_index "relationships", ["uuid"], name: "index_relationships_on_uuid", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   default: "", null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "system_groups", force: :cascade do |t|
    t.integer  "lock_version", limit: 4
    t.string   "name",         limit: 255
    t.string   "uuid",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "taggable_type", limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.integer  "lock_version", limit: 4
    t.integer  "user_id",      limit: 4
    t.string   "name",         limit: 255
    t.string   "uuid",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "shared"
  end

  add_index "user_groups", ["shared"], name: "shary", using: :btree
  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "full_name",             limit: 255
    t.string   "name",                  limit: 255
    t.string   "email",                 limit: 255
    t.datetime "last_login"
    t.boolean  "active"
    t.string   "password",              limit: 255
    t.string   "activation_hash",       limit: 255
    t.string   "locale",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",          limit: 4,   default: 0
    t.datetime "expires_at"
    t.boolean  "terms_accepted",                    default: false
    t.string   "login_attempts",        limit: 255
    t.boolean  "relation_admin"
    t.boolean  "authority_group_admin"
    t.boolean  "user_admin"
    t.boolean  "collection_admin"
    t.boolean  "kind_admin"
    t.boolean  "developer"
    t.boolean  "credential_admin"
    t.boolean  "admin"
    t.integer  "default_collection_id", limit: 4
    t.string   "home_page",             limit: 255
    t.integer  "collection_id",         limit: 4
    t.integer  "credential_id",         limit: 4
    t.boolean  "rating_admin"
    t.string   "parent_username",       limit: 255
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["parent_username"], name: "index_users_on_parent_username", using: :btree

end

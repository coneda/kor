# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_07_04_204545) do
  create_table "authority_group_categories", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["lft", "rgt", "parent_id"], name: "agc_hierarchy_index"
  end

  create_table "authority_groups", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name"
    t.string "uuid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "authority_group_category_id"
    t.index ["authority_group_category_id"], name: "index_authority_groups_on_authority_group_category_id"
  end

  create_table "authority_groups_entities", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "entity_id"
    t.integer "authority_group_id"
    t.index ["authority_group_id"], name: "index_authority_groups_entities_on_authority_group_id"
    t.index ["entity_id"], name: "index_authority_groups_entities_on_entity_id"
  end

  create_table "collections", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "collections_credentials", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "credential_id"
    t.string "policy"
    t.index ["collection_id", "credential_id", "policy"], name: "master"
  end

  create_table "credentials", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "lock_version", default: 0
    t.index ["name"], name: "index_credentials_on_name"
  end

  create_table "credentials_users", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.integer "credential_id"
    t.index ["credential_id"], name: "index_credentials_users_on_credential_id"
    t.index ["user_id", "credential_id"], name: "index_credentials_users_on_user_id_and_credential_id", unique: true
    t.index ["user_id"], name: "index_credentials_users_on_user_id"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.mediumtext "handler"
    t.mediumtext "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "directed_relationships", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "relation_id"
    t.integer "relationship_id"
    t.boolean "is_reverse"
    t.string "relation_name"
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "position", default: 0
    t.index ["from_id"], name: "index_directed_relationships_on_from_id"
    t.index ["relation_id", "is_reverse", "from_id", "to_id"], name: "ally"
    t.index ["relation_id"], name: "index_directed_relationships_on_relation_id"
    t.index ["to_id"], name: "index_directed_relationships_on_to_id"
  end

  create_table "downloads", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid"
    t.string "file_name"
    t.string "content_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["uuid"], name: "index_downloads_on_uuid"
  end

  create_table "entities", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.string "distinct_name"
    t.text "comment"
    t.integer "kind_id"
    t.integer "collection_id"
    t.integer "creator_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.string "no_name_statement"
    t.integer "updater_id"
    t.string "subtype"
    t.integer "medium_id"
    t.text "attachment"
    t.datetime "deleted_at", precision: nil
    t.string "sort_name"
    t.index ["collection_id", "kind_id"], name: "collections_kinds"
    t.index ["created_at"], name: "index_entities_on_created_at"
    t.index ["creator_id"], name: "index_entities_on_user_id"
    t.index ["distinct_name"], name: "index_entities_on_distinct_name"
    t.index ["id", "deleted_at"], name: "deleted_at_partial"
    t.index ["kind_id", "deleted_at"], name: "typey"
    t.index ["name"], name: "index_entities_on_name"
    t.index ["uuid"], name: "index_entities_on_uuid"
  end

  create_table "entities_system_groups", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "entity_id"
    t.integer "system_group_id"
    t.index ["entity_id"], name: "index_entities_system_groups_on_entity_id"
    t.index ["system_group_id"], name: "index_entities_system_groups_on_system_group_id"
  end

  create_table "entities_tags", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "entity_id"
    t.integer "tag_id"
    t.index ["entity_id", "tag_id"], name: "index_entities_tags_on_entity_id_and_tag_id", unique: true
  end

  create_table "entities_user_groups", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "entity_id"
    t.integer "user_group_id"
    t.index ["entity_id"], name: "index_entities_user_groups_on_entity_id"
    t.index ["user_group_id"], name: "index_entities_user_groups_on_user_group_id"
  end

  create_table "entity_datings", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "entity_id"
    t.string "label"
    t.string "dating_string"
    t.integer "from_day"
    t.integer "to_day"
    t.index ["entity_id"], name: "index_entity_datings_on_entity_id"
    t.index ["from_day", "to_day"], name: "timely"
  end

  create_table "fields", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "kind_id"
    t.string "type"
    t.string "name"
    t.string "show_label"
    t.string "form_label"
    t.string "search_label"
    t.text "settings"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_identifier"
    t.string "uuid"
    t.integer "position"
    t.boolean "mandatory"
  end

  create_table "generators", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "kind_id"
    t.string "name"
    t.text "directive"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "position"
  end

  create_table "identifiers", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "kind"
    t.string "value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "entity_id"
    t.index ["value", "kind"], name: "index_identifiers_on_value_and_kind"
    t.index ["value"], name: "index_identifiers_on_value"
  end

  create_table "kind_inheritances", primary_key: "false", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "kinds", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.text "description"
    t.text "settings"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.string "plural_name"
    t.datetime "deleted_at", precision: nil
    t.boolean "abstract"
    t.string "url"
    t.string "schema"
    t.index ["id", "deleted_at"], name: "deleted_at_partial"
  end

  create_table "media", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.integer "image_updated_at"
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.integer "document_updated_at"
    t.string "datahash"
    t.string "original_url"
    t.boolean "cache"
    t.string "state"
    t.boolean "document_processing"
    t.boolean "image_processing"
  end

  create_table "publishments", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid"
    t.string "name"
    t.datetime "valid_until", precision: nil
    t.integer "user_group_id"
    t.index ["user_id"], name: "index_publishments_on_user_id"
  end

  create_table "relation_inheritances", primary_key: "false", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "child_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "relations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "uuid"
    t.string "name"
    t.string "reverse_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.text "description"
    t.datetime "deleted_at", precision: nil
    t.string "url"
    t.boolean "abstract"
    t.integer "from_kind_id"
    t.integer "to_kind_id"
    t.string "schema"
    t.string "identifier"
    t.string "reverse_identifier"
    t.index ["id", "deleted_at"], name: "deleted_at_partial"
    t.index ["name"], name: "index_relations_on_name"
    t.index ["reverse_name"], name: "index_relations_on_reverse_name"
  end

  create_table "relationship_datings", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "relationship_id"
    t.string "label"
    t.string "dating_string"
    t.integer "from_day"
    t.integer "to_day"
    t.integer "lock_version", default: 0
    t.index ["from_day", "to_day"], name: "timely"
    t.index ["relationship_id"], name: "rely"
  end

  create_table "relationships", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "uuid"
    t.integer "owner_id"
    t.integer "relation_id"
    t.integer "from_id"
    t.integer "to_id"
    t.text "properties"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.integer "normal_id"
    t.integer "reversal_id"
    t.datetime "deleted_at", precision: nil
    t.index ["from_id"], name: "index_relationships_on_from_id"
    t.index ["id", "deleted_at"], name: "deleted_at_partial"
    t.index ["relation_id", "deleted_at"], name: "typey"
    t.index ["relation_id", "from_id", "to_id"], name: "index_relationships_on_relation_id_and_from_id_and_to_id"
    t.index ["relation_id"], name: "index_relationships_on_relation_id"
    t.index ["to_id"], name: "index_relationships_on_to_id"
    t.index ["uuid"], name: "index_relationships_on_uuid"
  end

  create_table "system_groups", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.string "name"
    t.string "uuid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "taggings", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type"
    t.string "context"
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_groups", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "lock_version", default: 0
    t.integer "user_id"
    t.string "name"
    t.string "uuid"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "shared"
    t.index ["shared"], name: "shary"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "full_name"
    t.string "name"
    t.string "email"
    t.datetime "last_login", precision: nil
    t.boolean "active"
    t.string "password"
    t.string "activation_hash"
    t.string "locale"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.datetime "expires_at", precision: nil
    t.boolean "terms_accepted", default: false
    t.string "login_attempts"
    t.boolean "relation_admin"
    t.boolean "authority_group_admin"
    t.boolean "kind_admin"
    t.boolean "admin"
    t.integer "default_collection_id"
    t.string "home_page"
    t.integer "collection_id"
    t.integer "credential_id"
    t.string "parent_username"
    t.string "api_key"
    t.text "storage"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["parent_username"], name: "index_users_on_parent_username"
  end

end

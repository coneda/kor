ActiveRecord::Schema.define(version: 20210305220358) do

  create_table "authority_group_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "lock_version", default: 0
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lft", "rgt", "parent_id"], name: "agc_hierarchy_index", using: :btree
  end

  create_table "authority_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "lock_version",                default: 0
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authority_group_category_id"
    t.index ["authority_group_category_id"], name: "index_authority_groups_on_authority_group_category_id", using: :btree
  end

  create_table "authority_groups_entities", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "entity_id"
    t.integer "authority_group_id"
    t.index ["authority_group_id"], name: "index_authority_groups_entities_on_authority_group_id", using: :btree
    t.index ["entity_id"], name: "index_authority_groups_entities_on_entity_id", using: :btree
  end

  create_table "collections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "lock_version", default: 0
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections_credentials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "collection_id"
    t.integer "credential_id"
    t.string  "policy"
    t.index ["collection_id", "credential_id", "policy"], name: "master", using: :btree
  end

  create_table "credentials", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name"
    t.text    "description",  limit: 16777215
    t.integer "lock_version",                  default: 0
    t.index ["name"], name: "index_credentials_on_name", using: :btree
  end

  create_table "credentials_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "credential_id"
    t.index ["credential_id"], name: "index_credentials_users_on_credential_id", using: :btree
    t.index ["user_id", "credential_id"], name: "index_credentials_users_on_user_id_and_credential_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_credentials_users_on_user_id", using: :btree
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "priority",                      default: 0
    t.integer  "attempts",                      default: 0
    t.text     "handler",    limit: 4294967295
    t.text     "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "directed_relationships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "relation_id"
    t.integer  "relationship_id"
    t.boolean  "is_reverse"
    t.string   "relation_name"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["from_id"], name: "index_directed_relationships_on_from_id", using: :btree
    t.index ["relation_id", "is_reverse", "from_id", "to_id"], name: "ally", using: :btree
    t.index ["relation_id"], name: "index_directed_relationships_on_relation_id", using: :btree
    t.index ["to_id"], name: "index_directed_relationships_on_to_id", using: :btree
  end

  create_table "downloads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "file_name"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uuid"], name: "index_downloads_on_uuid", using: :btree
  end

  create_table "entities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "distinct_name"
    t.text     "comment",           limit: 16777215
    t.integer  "kind_id"
    t.integer  "collection_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                       default: 0
    t.string   "no_name_statement"
    t.integer  "updater_id"
    t.string   "subtype"
    t.integer  "medium_id"
    t.text     "attachment",        limit: 16777215
    t.datetime "deleted_at"
    t.index ["collection_id", "kind_id"], name: "collections_kinds", using: :btree
    t.index ["created_at"], name: "index_entities_on_created_at", using: :btree
    t.index ["creator_id"], name: "index_entities_on_user_id", using: :btree
    t.index ["distinct_name"], name: "index_entities_on_distinct_name", using: :btree
    t.index ["id", "deleted_at"], name: "deleted_at_partial", using: :btree
    t.index ["kind_id", "deleted_at"], name: "typey", using: :btree
    t.index ["kind_id"], name: "index_entities_on_kind_id", using: :btree
    t.index ["medium_id"], name: "mediy", using: :btree
    t.index ["name"], name: "index_entities_on_name", using: :btree
    t.index ["uuid"], name: "index_entities_on_uuid", using: :btree
  end

  create_table "entities_system_groups", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "entity_id"
    t.integer "system_group_id"
    t.index ["entity_id"], name: "index_entities_system_groups_on_entity_id", using: :btree
    t.index ["system_group_id"], name: "index_entities_system_groups_on_system_group_id", using: :btree
  end

  create_table "entities_tags", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "entity_id"
    t.integer "tag_id"
    t.index ["entity_id", "tag_id"], name: "index_entities_tags_on_entity_id_and_tag_id", unique: true, using: :btree
  end

  create_table "entities_user_groups", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "entity_id"
    t.integer "user_group_id"
    t.index ["entity_id"], name: "index_entities_user_groups_on_entity_id", using: :btree
    t.index ["user_group_id"], name: "index_entities_user_groups_on_user_group_id", using: :btree
  end

  create_table "entity_datings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "lock_version",  default: 0
    t.integer "entity_id"
    t.string  "label"
    t.string  "dating_string"
    t.integer "from_day"
    t.integer "to_day"
    t.index ["entity_id"], name: "index_entity_datings_on_entity_id", using: :btree
    t.index ["from_day", "to_day"], name: "timely", using: :btree
  end

  create_table "fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "kind_id"
    t.string   "type"
    t.string   "name"
    t.string   "show_label"
    t.string   "form_label"
    t.string   "search_label"
    t.text     "settings",      limit: 16777215
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_identifier"
    t.string   "uuid"
    t.integer  "position"
    t.boolean  "mandatory"
  end

  create_table "generators", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "kind_id"
    t.string   "name"
    t.text     "directive",  limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "position"
  end

  create_table "identifiers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "kind"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.index ["value", "kind"], name: "index_identifiers_on_value_and_kind", using: :btree
    t.index ["value"], name: "index_identifiers_on_value", using: :btree
  end

  create_table "kind_inheritances", primary_key: "false", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kinds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "uuid"
    t.string   "name"
    t.text     "description",  limit: 16777215
    t.text     "settings",     limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                  default: 0
    t.string   "plural_name"
    t.datetime "deleted_at"
    t.boolean  "abstract"
    t.string   "url"
    t.string   "schema"
    t.index ["id", "deleted_at"], name: "deleted_at_partial", using: :btree
  end

  create_table "media", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "lock_version",          default: 0
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

  create_table "publishments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "name"
    t.datetime "valid_until"
    t.integer  "user_group_id"
    t.index ["user_id"], name: "index_publishments_on_user_id", using: :btree
  end

  create_table "relation_inheritances", primary_key: "false", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "reverse_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                  default: 0
    t.text     "description",  limit: 16777215
    t.datetime "deleted_at"
    t.string   "url"
    t.boolean  "abstract"
    t.integer  "from_kind_id"
    t.integer  "to_kind_id"
    t.string   "schema"
    t.string   "identifier"
    t.string   "reverse_identifier"
    t.index ["id", "deleted_at"], name: "deleted_at_partial", using: :btree
    t.index ["name"], name: "index_relations_on_name", using: :btree
    t.index ["reverse_name"], name: "index_relations_on_reverse_name", using: :btree
  end

  create_table "relationship_datings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "relationship_id"
    t.string  "label"
    t.string  "dating_string"
    t.integer "from_day"
    t.integer "to_day"
    t.integer "lock_version",    default: 0
    t.index ["from_day", "to_day"], name: "timely", using: :btree
    t.index ["relationship_id"], name: "rely", using: :btree
  end

  create_table "relationships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "uuid"
    t.integer  "owner_id"
    t.integer  "relation_id"
    t.integer  "from_id"
    t.integer  "to_id"
    t.text     "properties",   limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                  default: 0
    t.integer  "normal_id"
    t.integer  "reversal_id"
    t.datetime "deleted_at"
    t.index ["from_id"], name: "index_relationships_on_from_id", using: :btree
    t.index ["id", "deleted_at"], name: "deleted_at_partial", using: :btree
    t.index ["relation_id", "deleted_at"], name: "typey", using: :btree
    t.index ["relation_id", "from_id", "to_id"], name: "index_relationships_on_relation_id_and_from_id_and_to_id", using: :btree
    t.index ["relation_id"], name: "index_relationships_on_relation_id", using: :btree
    t.index ["to_id"], name: "index_relationships_on_to_id", using: :btree
    t.index ["uuid"], name: "index_relationships_on_uuid", using: :btree
  end

  create_table "system_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "lock_version", default: 0
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name",                       collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "user_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "lock_version", default: 0
    t.integer  "user_id"
    t.string   "name"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "shared"
    t.index ["shared"], name: "shary", using: :btree
    t.index ["user_id"], name: "index_user_groups_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
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
    t.integer  "lock_version",                           default: 0
    t.datetime "expires_at"
    t.boolean  "terms_accepted",                         default: false
    t.string   "login_attempts"
    t.boolean  "relation_admin"
    t.boolean  "authority_group_admin"
    t.boolean  "kind_admin"
    t.boolean  "admin"
    t.integer  "default_collection_id"
    t.string   "home_page"
    t.integer  "collection_id"
    t.integer  "credential_id"
    t.string   "parent_username"
    t.string   "api_key"
    t.text     "storage",               limit: 16777215
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
    t.index ["parent_username"], name: "index_users_on_parent_username", using: :btree
  end

end

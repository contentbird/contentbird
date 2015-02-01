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

ActiveRecord::Schema.define(version: 20140408112729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_settings", force: true do |t|
    t.string   "key",        limit: 50
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_settings", ["key"], name: "index_app_settings_on_key", using: :btree

  create_table "channel_subscriptions", force: true do |t|
    t.integer  "contact_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channel_subscriptions", ["contact_id", "channel_id"], name: "index_channel_subscriptions_on_contact_id_and_channel_id", unique: true, using: :btree

  create_table "channels", force: true do |t|
    t.string   "name"
    t.datetime "closed_at"
    t.string   "url_prefix"
    t.integer  "owner_id"
    t.string   "access_token"
    t.string   "type",                  default: "CB::Core::WebsiteChannel"
    t.string   "provider"
    t.string   "provider_oauth_token"
    t.string   "provider_oauth_secret"
    t.string   "css"
    t.string   "baseline"
    t.string   "cover"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_social_feed",     default: false
  end

  add_index "channels", ["access_token"], name: "index_channels_on_access_token", unique: true, using: :btree
  add_index "channels", ["name"], name: "index_channels_on_name", using: :btree
  add_index "channels", ["owner_id"], name: "index_channels_on_owner_id", using: :btree
  add_index "channels", ["provider"], name: "index_channels_on_provider", using: :btree
  add_index "channels", ["type"], name: "index_channels_on_type", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "contacts", ["email", "owner_id"], name: "index_contacts_on_email_and_owner_id", unique: true, using: :btree

  create_table "content_properties", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "father_type_id"
    t.integer  "content_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "content_properties", ["content_type_id"], name: "index_content_properties_on_content_type_id", using: :btree
  add_index "content_properties", ["father_type_id", "position"], name: "index_content_properties_on_father_type_id_and_position", using: :btree

  create_table "content_type_usages", force: true do |t|
    t.integer  "user_id"
    t.integer  "content_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_type_usages", ["user_id", "content_type_id"], name: "index_content_type_usages_on_user_id_and_content_type_id", unique: true, using: :btree

  create_table "content_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "composite",                default: true
    t.integer  "owner_id"
    t.integer  "origin_type_id"
    t.string   "title"
    t.integer  "contents_count",           default: 0,     null: false
    t.string   "title_label"
    t.boolean  "usable_by_default",        default: false
    t.boolean  "by_platform",              default: false
    t.string   "picto"
    t.boolean  "available_to_basic_users", default: true
  end

  add_index "content_types", ["composite"], name: "index_content_types_on_composite", using: :btree
  add_index "content_types", ["name"], name: "index_content_types_on_name", using: :btree
  add_index "content_types", ["origin_type_id"], name: "index_content_types_on_origin_type_id", using: :btree
  add_index "content_types", ["owner_id"], name: "index_content_types_on_owner_id", using: :btree
  add_index "content_types", ["usable_by_default"], name: "index_content_types_on_usable_by_default", using: :btree

  create_table "contents", force: true do |t|
    t.string   "title"
    t.integer  "owner_id"
    t.integer  "content_type_id"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "publications_count",       default: 0, null: false
    t.text     "exportable_properties"
    t.string   "first_image_property_key"
    t.string   "first_image_property_url"
  end

  add_index "contents", ["content_type_id"], name: "index_contents_on_content_type_id", using: :btree
  add_index "contents", ["owner_id", "slug"], name: "index_contents_on_owner_id_and_slug", unique: true, using: :btree
  add_index "contents", ["owner_id"], name: "index_contents_on_owner_id", using: :btree

  create_table "leads", force: true do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leads", ["token"], name: "index_leads_on_token", using: :btree

  create_table "publications", force: true do |t|
    t.integer  "channel_id"
    t.integer  "content_id"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url_alias"
    t.string   "provider_ref"
    t.datetime "deleted_at"
    t.datetime "expire_at"
    t.datetime "last_failed_unpublish_at"
    t.string   "last_failed_unpublish_message"
    t.integer  "failed_unpublish_count",        default: 0
  end

  add_index "publications", ["channel_id"], name: "index_publications_on_channel_id", using: :btree
  add_index "publications", ["content_id"], name: "index_publications_on_content_id", using: :btree
  add_index "publications", ["deleted_at", "expire_at", "failed_unpublish_count"], name: "index_publications_on_del_expire_failed_unpublish", using: :btree
  add_index "publications", ["deleted_at"], name: "index_publications_on_deleted_at", using: :btree
  add_index "publications", ["published_at"], name: "index_publications_on_published_at", using: :btree
  add_index "publications", ["url_alias", "channel_id"], name: "index_publications_on_url_alias_and_channel_id", unique: true, using: :btree

  create_table "sections", force: true do |t|
    t.string   "slug"
    t.string   "title"
    t.integer  "position"
    t.integer  "channel_id"
    t.integer  "content_type_id"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "forewords"
  end

  add_index "sections", ["channel_id", "slug"], name: "index_sections_on_channel_id_and_slug", unique: true, using: :btree
  add_index "sections", ["channel_id"], name: "index_sections_on_channel_id", using: :btree
  add_index "sections", ["content_type_id"], name: "index_sections_on_content_type_id", using: :btree
  add_index "sections", ["position"], name: "index_sections_on_position", using: :btree

  create_table "users", force: true do |t|
    t.string   "nest_name",                                 null: false
    t.string   "email",                     default: "",    null: false
    t.string   "encrypted_password",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "platform_user",             default: false
    t.boolean  "admin",                     default: false
    t.string   "locale"
    t.boolean  "advanced_user",             default: false
    t.string   "last_announcement_clicked"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nest_name"], name: "index_users_on_nest_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

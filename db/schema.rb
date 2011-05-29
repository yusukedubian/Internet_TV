# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100713085646) do

  create_table "acceptance_masters", :force => true do |t|
    t.string   "name"
    t.integer  "content_type"
    t.string   "table_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "acceptances", :force => true do |t|
    t.integer  "user_id"
    t.integer  "content_id"
    t.integer  "acceptance_master_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", :force => true do |t|
    t.integer  "user_id"
    t.integer  "channels_type_id"
    t.integer  "channel_no"
    t.string   "name",               :limit => 80
    t.string   "category",           :limit => 80
    t.string   "background"
    t.integer  "public_flag"
    t.integer  "width"
    t.integer  "height"
    t.integer  "create_type"
    t.string   "description",        :limit => 2048
    t.string   "link_info",          :limit => 512
    t.string   "other_info",         :limit => 512
    t.string   "thumbnail_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "uploaded_flg",                       :default => true
    t.boolean  "group_flg",                          :default => false
  end

  create_table "channels_types", :force => true do |t|
    t.string   "name"
    t.string   "channels_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "company_uniq_id",      :limit => 10
    t.string   "company_name",         :limit => 50
    t.string   "company_name_kana",    :limit => 50
    t.string   "president_name",       :limit => 20
    t.string   "president_phone",      :limit => 20
    t.string   "president_phone_ext",  :limit => 10
    t.string   "president_zipcode",    :limit => 10
    t.string   "president_prefecture", :limit => 10
    t.string   "president_city",       :limit => 100
    t.string   "president_building",   :limit => 100
    t.string   "president_remarks",    :limit => 500
    t.string   "admin_name",           :limit => 20
    t.string   "admin_name_kana",      :limit => 20
    t.string   "admin_departmemt",     :limit => 20
    t.string   "admin_post",           :limit => 20
    t.string   "admin_phone",          :limit => 20
    t.string   "admin_phone_ext",      :limit => 10
    t.string   "admin_zipcode",        :limit => 10
    t.string   "admin_prefecture",     :limit => 10
    t.string   "admin_city",           :limit => 100
    t.string   "admin_building",       :limit => 100
    t.string   "admin_remarks",        :limit => 500
    t.integer  "account_no",           :limit => 8
    t.integer  "disc_size",            :limit => 8
    t.string   "register",             :limit => 20
    t.boolean  "del_flg",                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents", :force => true do |t|
    t.integer  "player_id"
    t.integer  "page_id"
    t.integer  "width"
    t.integer  "height"
    t.integer  "x_pos"
    t.integer  "y_pos"
    t.integer  "contents_seq"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contents_properties", :force => true do |t|
    t.integer  "content_id"
    t.string   "property_key"
    t.string   "property_value", :limit => 2048
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forgot_passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "index_messages", :force => true do |t|
    t.string   "body",       :limit => 200
    t.boolean  "no_end_flg",                :default => false
    t.boolean  "del_flg",                   :default => false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "message_code"
    t.string   "message_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mypages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "page_no"
    t.string   "name",                    :limit => 80
    t.string   "category",                :limit => 80
    t.integer  "switchtime"
    t.string   "background"
    t.string   "backgroundfile"
    t.integer  "background_display_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_accesses", :force => true do |t|
    t.integer  "company_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.integer  "player_no"
    t.string   "name"
    t.string   "guide_text"
    t.string   "playerclass"
    t.string   "playerview"
    t.string   "runtime_get_type"
    t.string   "runtime_create_type"
    t.string   "runtime_config_table"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title_img"
    t.string   "logo_img"
    t.boolean  "del_flg",              :default => false
    t.boolean  "default",              :default => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_kana"
  end

  create_table "runtime_config_mails", :force => true do |t|
    t.integer  "content_id"
    t.integer  "channel_no"
    t.integer  "page_no"
    t.string   "control_no"
    t.string   "subject",             :limit => 1024
    t.string   "base_date_unit"
    t.integer  "base_date"
    t.string   "extract_period_unit"
    t.integer  "extract_period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runtime_config_rsses", :force => true do |t|
    t.integer  "content_id"
    t.integer  "channel_no"
    t.integer  "page_no"
    t.string   "control_no"
    t.string   "line_no"
    t.string   "rss_site_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "runtime_data_mails", :force => true do |t|
    t.integer  "user_id"
    t.string   "mail_recieved_id"
    t.datetime "send_date"
    t.string   "mail_from",        :limit => 1024
    t.string   "mail_to",          :limit => 1024
    t.string   "mail_cc",          :limit => 1024
    t.string   "subject",          :limit => 1024
    t.string   "body",             :limit => 4096
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name", :limit => 10
  end

  create_table "template_content_properties", :force => true do |t|
    t.integer  "template_content_id"
    t.string   "property_key"
    t.string   "property_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_contents", :force => true do |t|
    t.integer  "player_id"
    t.integer  "template_page_id"
    t.integer  "width"
    t.integer  "height"
    t.integer  "x_pos"
    t.integer  "y_pos"
    t.integer  "contents_seq"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_pages", :force => true do |t|
    t.integer  "template_page_no"
    t.string   "name"
    t.string   "category"
    t.integer  "switchtime"
    t.string   "background"
    t.string   "backgroundfile"
    t.integer  "width"
    t.integer  "height"
    t.string   "description"
    t.string   "link_info"
    t.string   "other_info"
    t.string   "thumbnail_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tv_channels", :force => true do |t|
    t.integer  "channel_no"
    t.string   "name",                :limit => 80
    t.string   "category",            :limit => 80
    t.integer  "public_flag"
    t.string   "description",         :limit => 2048
    t.string   "page_number",         :limit => 512
    t.string   "display_size",        :limit => 512
    t.string   "auther",              :limit => 512
    t.string   "link_info",           :limit => 512
    t.string   "other_info",          :limit => 512
    t.string   "thumbnail_filename",  :limit => 256
    t.string   "thumbnail_link_path", :limit => 256
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_properties", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "domain"
    t.string   "smtp_address"
    t.string   "pop3_address"
    t.string   "smtp_port"
    t.string   "pop3_port"
    t.string   "authentication"
    t.string   "auth_user_name"
    t.string   "auth_password"
    t.string   "google_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 200
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.boolean  "enabled",                                  :default => true
    t.string   "user_name",                 :limit => 40
    t.string   "name",                      :limit => 80
    t.string   "department",                :limit => 80
    t.integer  "company_id"
  end

  create_table "yaml_db_forms", :force => true do |t|
    t.integer  "user_id"
    t.string   "file_path"
    t.string   "form_name"
    t.string   "form_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

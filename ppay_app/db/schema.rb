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

ActiveRecord::Schema[7.0].define(version: 2023_07_18_110126) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "advertisements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "direction"
    t.string "national_currency"
    t.string "cryptocurrency", default: "USDT"
    t.string "payment_system"
    t.integer "payment_system_type", default: 0
    t.decimal "min_summ", precision: 12, scale: 2
    t.decimal "max_summ", precision: 12, scale: 2
    t.string "card_number"
    t.boolean "autoacceptance", default: false
    t.string "comment"
    t.string "operator_contact"
    t.string "exchange_rate_type"
    t.string "exchange_rate_source"
    t.decimal "percent", precision: 4, scale: 2
    t.decimal "min_fix_price", precision: 12, scale: 2
    t.boolean "status", default: false
    t.boolean "hidden", default: false
    t.integer "account_id"
    t.bigint "processer_id"
    t.string "payment_link"
    t.index ["processer_id"], name: "index_advertisements_on_processer_id"
  end

  create_table "api_keys", force: :cascade do |t|
    t.integer "bearer_id", null: false
    t.string "bearer_type", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bearer_id", "bearer_type"], name: "index_api_keys_on_bearer_id_and_bearer_type"
    t.index ["token"], name: "index_api_keys_on_token", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "balance_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "requests_type", default: 0, null: false
    t.decimal "amount", precision: 12, scale: 2
    t.integer "status", default: 0, null: false
    t.string "crypto_address"
    t.text "short_comment"
  end

  create_table "balances", force: :cascade do |t|
    t.decimal "amount", default: "0.0", null: false
    t.string "balanceable_type", null: false
    t.bigint "balanceable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "in_national_currency", default: false
    t.string "currency", default: "USDT"
    t.index ["balanceable_type", "balanceable_id"], name: "index_balances_on_balanceable"
  end

  create_table "cards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.string "expiration"
    t.string "first_name"
    t.string "last_name"
    t.string "cvv"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "payment_id", null: false
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_chats_on_payment_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "author_nickname"
    t.string "author_type"
    t.text "text"
    t.integer "user_id"
    t.string "user_ip"
    t.string "user_agent"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
  end

  create_table "commissions", force: :cascade do |t|
    t.integer "commission_type"
    t.decimal "commission", precision: 15, scale: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "merchant_method_id", null: false
    t.index ["commission_type", "merchant_method_id"], name: "index_commissions_uniqueness", unique: true
    t.index ["merchant_method_id"], name: "index_commissions_on_merchant_method_id"
  end

  create_table "crypto_wallets", force: :cascade do |t|
    t.string "address"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_crypto_wallets_on_user_id"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "exchange_portals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "form_customizations", force: :cascade do |t|
    t.string "button_color"
    t.string "background_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "merchant_id"
    t.string "name"
    t.boolean "default", default: false, null: false
    t.index ["merchant_id"], name: "index_form_customizations_on_merchant_id"
  end

  create_table "incoming_requests", force: :cascade do |t|
    t.string "type"
    t.string "app"
    t.string "api_key"
    t.string "from"
    t.string "to"
    t.string "message"
    t.string "res_sn"
    t.string "imsi"
    t.string "imei"
    t.string "com"
    t.string "simno"
    t.string "softwareid"
    t.string "custmemo"
    t.integer "sendstat"
    t.string "user_agent"
    t.string "text"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masks", force: :cascade do |t|
    t.string "name"
    t.string "sms_mask"
    t.string "push_mask"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchant_methods", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.bigint "payment_system_id", null: false
    t.string "direction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "payment_system_id", "direction"], name: "index_merchant_methods_uniqueness", unique: true
    t.index ["merchant_id"], name: "index_merchant_methods_on_merchant_id"
    t.index ["payment_system_id"], name: "index_merchant_methods_on_payment_system_id"
  end

  create_table "national_currencies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_systems", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "national_currency_id", null: false
    t.index ["name", "national_currency_id"], name: "index_payment_systems_uniqueness", unique: true
    t.index ["national_currency_id"], name: "index_payment_systems_on_national_currency_id"
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "direction"
    t.string "cryptocurrency", default: "USDT", null: false
    t.decimal "cryptocurrency_amount", precision: 12, scale: 2
    t.string "national_currency"
    t.decimal "national_currency_amount", precision: 12, scale: 2
    t.string "payment_system"
    t.string "payment_status"
    t.string "cancelled_on_status"
    t.integer "advertisement_id"
    t.integer "merchant_id"
    t.integer "rate_snapshot_id"
    t.string "first_ip"
    t.string "first_user_agent"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.string "external_order_id"
    t.string "type", default: "Deposit", null: false
    t.datetime "status_changed_at"
    t.string "card_number"
    t.boolean "arbitration", default: false
    t.bigint "support_id"
    t.string "redirect_url"
    t.string "callback_url"
    t.integer "cancellation_reason"
    t.integer "unique_amount"
    t.integer "processing_type", default: 0
    t.decimal "initial_amount", precision: 12, scale: 2
    t.string "locale"
    t.bigint "form_customization_id"
    t.index "((uuid)::text) gin_trgm_ops", name: "idx_payments_uuid_trgm", using: :gin
    t.index ["form_customization_id"], name: "index_payments_on_form_customization_id"
    t.index ["support_id"], name: "index_payments_on_support_id"
  end

  create_table "rate_snapshots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "direction"
    t.string "cryptocurrency"
    t.string "payment_system"
    t.integer "position_number"
    t.integer "exchange_portal_id"
    t.decimal "value"
    t.string "national_currency"
    t.decimal "adv_amount"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "receive_requests_enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "from_balance_id", default: 0
    t.bigint "to_balance_id", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "transaction_type", default: 0, null: false
    t.string "transactionable_type"
    t.bigint "transactionable_id"
    t.decimal "national_currency_amount", precision: 12, scale: 2
    t.index ["from_balance_id"], name: "index_transactions_on_from_balance_id"
    t.index ["to_balance_id"], name: "index_transactions_on_to_balance_id"
    t.index ["transactionable_type", "transactionable_id"], name: "index_transactions_on_transactionable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "nickname"
    t.string "name"
    t.string "surname"
    t.string "phone"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "working_group_id"
    t.bigint "agent_id"
    t.decimal "deposit_commission", precision: 15, scale: 10
    t.decimal "withdrawal_commission", precision: 15, scale: 10
    t.string "usdt_trc20_address"
    t.boolean "check_required", default: true
    t.integer "unique_amount", default: 0
    t.string "telegram"
    t.string "telegram_id"
    t.integer "ftd_payment_exec_time_in_sec", default: 480
    t.integer "regular_payment_exec_time_in_sec", default: 1200
    t.decimal "ftd_payment_default_summ", precision: 12, scale: 2
    t.boolean "differ_ftd_and_other_payments", default: false
    t.boolean "receive_requests_enabled", default: false
    t.index ["agent_id"], name: "index_users_on_agent_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "working_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "withdrawal_commission", precision: 15, scale: 10
    t.decimal "deposit_commission", precision: 15, scale: 10
    t.string "name"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "payments"
  add_foreign_key "chats", "users"
  add_foreign_key "commissions", "merchant_methods"
  add_foreign_key "crypto_wallets", "users"
  add_foreign_key "merchant_methods", "payment_systems"
  add_foreign_key "merchant_methods", "users", column: "merchant_id"
  add_foreign_key "payment_systems", "national_currencies"
  add_foreign_key "payments", "form_customizations"
end

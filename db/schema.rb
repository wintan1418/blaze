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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_104022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "bookable_id", null: false
    t.string "bookable_type", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.datetime "paid_at"
    t.string "payment_status", default: "unpaid", null: false
    t.string "reference", null: false
    t.integer "seats", default: 1, null: false
    t.string "status", default: "pending", null: false
    t.integer "total_price_kobo", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["bookable_type", "bookable_id"], name: "index_bookings_on_bookable"
    t.index ["payment_status"], name: "index_bookings_on_payment_status"
    t.index ["reference"], name: "index_bookings_on_reference", unique: true
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "gaming_consoles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "console_type"
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_gaming_consoles_on_location_id"
  end

  create_table "gaming_slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.bigint "gaming_console_id", null: false
    t.integer "price_kobo", default: 0, null: false
    t.datetime "starts_at", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["gaming_console_id"], name: "index_gaming_slots_on_gaming_console_id"
    t.index ["starts_at"], name: "index_gaming_slots_on_starts_at"
    t.index ["status"], name: "index_gaming_slots_on_status"
  end

  create_table "hero_slides", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "image_url"
    t.string "kind", null: false
    t.string "meta"
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_hero_slides_on_active"
    t.index ["position"], name: "index_hero_slides_on_position"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "hero_image_url"
    t.string "name"
    t.string "phone"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_locations_on_slug", unique: true
  end

  create_table "loyalty_stamps", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "earned_at", null: false
    t.boolean "redeemed", default: false, null: false
    t.datetime "redeemed_at"
    t.bigint "redeemed_by_id"
    t.string "redemption_note"
    t.bigint "source_id"
    t.string "source_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["redeemed"], name: "index_loyalty_stamps_on_redeemed"
    t.index ["redeemed_by_id"], name: "index_loyalty_stamps_on_redeemed_by_id"
    t.index ["source_type", "source_id"], name: "index_loyalty_stamps_on_source"
    t.index ["user_id", "category"], name: "index_loyalty_stamps_on_user_id_and_category"
    t.index ["user_id"], name: "index_loyalty_stamps_on_user_id"
  end

  create_table "menu_categories", force: :cascade do |t|
    t.string "accent_color"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_menu_categories_on_slug", unique: true
  end

  create_table "menu_items", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.bigint "menu_category_id", null: false
    t.string "name"
    t.integer "preparation_time"
    t.integer "price_kobo", default: 0, null: false
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["menu_category_id"], name: "index_menu_items_on_menu_category_id"
    t.index ["slug"], name: "index_menu_items_on_slug", unique: true
  end

  create_table "offline_sales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "location_id"
    t.bigint "menu_item_id"
    t.text "notes"
    t.string "payment_method", default: "cash", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "recorded_by_id", null: false
    t.datetime "sold_at", null: false
    t.integer "total_kobo", default: 0, null: false
    t.integer "unit_price_kobo", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_offline_sales_on_location_id"
    t.index ["menu_item_id"], name: "index_offline_sales_on_menu_item_id"
    t.index ["payment_method"], name: "index_offline_sales_on_payment_method"
    t.index ["recorded_by_id"], name: "index_offline_sales_on_recorded_by_id"
    t.index ["sold_at"], name: "index_offline_sales_on_sold_at"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "menu_item_id", null: false
    t.string "name_snapshot"
    t.bigint "order_id", null: false
    t.integer "quantity", default: 1
    t.integer "unit_price_kobo", default: 0
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.text "delivery_address"
    t.string "delivery_city"
    t.integer "delivery_fee_kobo", default: 0, null: false
    t.text "delivery_notes"
    t.string "delivery_phone"
    t.string "delivery_status", default: "none", null: false
    t.datetime "dispatched_at"
    t.string "fulfillment", default: "pickup", null: false
    t.bigint "location_id", null: false
    t.text "notes"
    t.datetime "paid_at"
    t.string "payment_status", default: "unpaid", null: false
    t.string "reference"
    t.string "status", default: "pending", null: false
    t.integer "subtotal_kobo", default: 0, null: false
    t.integer "total_kobo", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["delivery_status"], name: "index_orders_on_delivery_status"
    t.index ["location_id"], name: "index_orders_on_location_id"
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_kobo", null: false
    t.string "authorization_url"
    t.string "channel"
    t.datetime "created_at", null: false
    t.string "currency", default: "NGN", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "paid_at"
    t.bigint "payable_id", null: false
    t.string "payable_type", null: false
    t.string "provider", default: "paystack", null: false
    t.string "provider_reference"
    t.string "reference", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
    t.index ["provider_reference"], name: "index_payments_on_provider_reference"
    t.index ["reference"], name: "index_payments_on_reference", unique: true
    t.index ["status"], name: "index_payments_on_status"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.bigint "reviewable_id", null: false
    t.string "reviewable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "screenings", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "poster_url"
    t.integer "price_kobo", default: 0, null: false
    t.bigint "screen_id", null: false
    t.string "slug"
    t.datetime "starts_at", null: false
    t.text "synopsis"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["screen_id"], name: "index_screenings_on_screen_id"
    t.index ["slug"], name: "index_screenings_on_slug", unique: true
    t.index ["starts_at"], name: "index_screenings_on_starts_at"
  end

  create_table "screens", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_screens_on_location_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.text "about_body", default: "Blaze Cafe started on a school campus in Ondo State as a single idea: a place where students, creatives and everyone in between could eat well, drink well, play on the best consoles and catch a film — all under one roof.\n\nToday we serve chef-cooked plates, craft drinks, 30-minute PlayStation sessions, and intimate cinema screenings. Everything we do is guided by one thing: good times that come alive.\n\nWe're growing across Ondo State — bringing the same energy, the same hospitality, and the same flame to every location."
    t.string "about_eyebrow", default: "About"
    t.string "about_headline", default: "The story behind the flame."
    t.string "accent_color", default: "F5A623", null: false
    t.string "ash_color", default: "13131A", null: false
    t.string "body_font", default: "Inter", null: false
    t.text "contact_body", default: "For bookings, private events, or just to say hi — reach us on any of the channels below."
    t.string "contact_email", default: "hello@blazecafe.ng"
    t.string "contact_eyebrow", default: "Contact"
    t.string "contact_headline", default: "Talk to us."
    t.string "contact_phone", default: "+234 812 000 1000"
    t.datetime "created_at", null: false
    t.text "cta_body", default: "Book a PlayStation session, reserve cinema seats, or just swing by. We're open daily from 10am."
    t.string "cta_headline", default: "Ready to come alive?"
    t.boolean "delivery_enabled", default: true, null: false
    t.integer "delivery_fee_kobo", default: 50000, null: false
    t.integer "delivery_free_over_kobo", default: 0, null: false
    t.text "delivery_note"
    t.integer "delivery_radius_km", default: 15, null: false
    t.string "dishes_eyebrow", default: "Signature dishes"
    t.string "dishes_headline", default: "Plates that slap."
    t.string "display_font", default: "Space Grotesk", null: false
    t.string "ember_color", default: "FF5A1F", null: false
    t.string "experiences_eyebrow", default: "Experiences"
    t.string "experiences_headline", default: "Four ways to come alive."
    t.text "footer_tagline", default: "Where good times come alive. Premium food, drinks, PlayStation gaming and private cinema — all under one roof across Ondo State."
    t.string "hero_cta_primary", default: "Explore the menu"
    t.string "hero_cta_secondary", default: "Book a session"
    t.string "hero_eyebrow", default: "Blaze · 001"
    t.string "hero_footer_mark", default: "Est. Ondo State · 2026"
    t.string "hero_headline_accent", default: "fire"
    t.string "hero_headline_line1", default: "Taste"
    t.string "hero_headline_line2", default: "the fire."
    t.string "hero_live_label", default: "Open now"
    t.text "hero_subtitle", default: "Chef-cooked African plates, ice-cold drinks, PlayStation sessions and private cinema — across Ondo State."
    t.string "ink_color", default: "0A0A0B", null: false
    t.string "instagram_url"
    t.string "logo_mark", default: "B", null: false
    t.string "logo_wordmark", default: "BLAZE.", null: false
    t.text "meta_description"
    t.string "primary_color", default: "E8341A", null: false
    t.jsonb "sections", default: {}, null: false
    t.string "site_name", default: "Blaze Cafe", null: false
    t.string "smoke_color", default: "1C1C24", null: false
    t.string "tagline", default: "Where Good Times Come Alive", null: false
    t.string "testimonial_author", default: "Ada, regular since day one"
    t.text "testimonial_quote", default: "The jollof hits different. The PS5 is clean. The cinema room is bigger than my bedroom. Blaze is the move in Ondo, period."
    t.string "tiktok_url"
    t.datetime "updated_at", null: false
    t.text "vibe_body", default: "Friends laughing over jollof. Controllers in hand. A cold drink between rounds. Blaze Cafe isn't just a place — it's how Ondo State unwinds."
    t.string "vibe_eyebrow", default: "The vibe"
    t.string "vibe_headline", default: "This is how we come alive."
    t.string "whatsapp_url"
    t.string "x_url"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "users"
  add_foreign_key "gaming_consoles", "locations"
  add_foreign_key "gaming_slots", "gaming_consoles"
  add_foreign_key "loyalty_stamps", "users"
  add_foreign_key "loyalty_stamps", "users", column: "redeemed_by_id"
  add_foreign_key "menu_items", "menu_categories"
  add_foreign_key "offline_sales", "locations"
  add_foreign_key "offline_sales", "menu_items"
  add_foreign_key "offline_sales", "users", column: "recorded_by_id"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "locations"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "reviews", "users"
  add_foreign_key "screenings", "screens"
  add_foreign_key "screens", "locations"
end

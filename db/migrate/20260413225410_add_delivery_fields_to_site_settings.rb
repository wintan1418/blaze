class AddDeliveryFieldsToSiteSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :site_settings, :delivery_enabled,      :boolean, default: true,  null: false
    add_column :site_settings, :delivery_fee_kobo,     :integer, default: 50000, null: false  # ₦500 default
    add_column :site_settings, :delivery_free_over_kobo, :integer, default: 0,   null: false  # 0 = never free
    add_column :site_settings, :delivery_radius_km,    :integer, default: 15,    null: false
    add_column :site_settings, :delivery_note,         :text
  end
end

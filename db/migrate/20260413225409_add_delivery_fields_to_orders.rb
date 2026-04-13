class AddDeliveryFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :subtotal_kobo,     :integer, default: 0, null: false
    add_column :orders, :delivery_fee_kobo, :integer, default: 0, null: false
    add_column :orders, :delivery_address,  :text
    add_column :orders, :delivery_city,     :string
    add_column :orders, :delivery_phone,    :string
    add_column :orders, :delivery_status,   :string,  default: "none", null: false
    add_column :orders, :delivery_notes,    :text
    add_column :orders, :dispatched_at,     :datetime
    add_column :orders, :delivered_at,      :datetime
    add_index  :orders, :delivery_status
  end
end

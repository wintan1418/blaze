class SetOrderDefaults < ActiveRecord::Migration[8.1]
  def change
    change_column_default :orders, :status,         from: nil, to: "pending"
    change_column_default :orders, :payment_status, from: nil, to: "unpaid"
    change_column_default :orders, :fulfillment,    from: nil, to: "pickup"
    change_column_default :orders, :total_kobo,     from: nil, to: 0
    change_column_null    :orders, :status,         false, "pending"
    change_column_null    :orders, :payment_status, false, "unpaid"
    change_column_null    :orders, :fulfillment,    false, "pickup"
    change_column_null    :orders, :total_kobo,     false, 0
    add_column            :orders, :paid_at, :datetime unless column_exists?(:orders, :paid_at)
    add_index             :orders, :status          unless index_exists?(:orders, :status)
    add_index             :orders, :payment_status  unless index_exists?(:orders, :payment_status)

    change_column_default :order_items, :quantity,        from: nil, to: 1
    change_column_default :order_items, :unit_price_kobo, from: nil, to: 0
  end
end

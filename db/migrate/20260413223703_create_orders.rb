class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user,     null: false, foreign_key: true
      t.references :location, null: true,  foreign_key: true
      t.string  :reference,     null: false
      t.string  :status,        default: "pending", null: false   # pending / preparing / ready / completed / cancelled
      t.string  :payment_status, default: "unpaid", null: false   # unpaid / paid / refunded
      t.string  :fulfillment,   default: "pickup",  null: false   # pickup / dine_in
      t.integer :total_kobo,    default: 0,         null: false
      t.text    :notes
      t.datetime :paid_at

      t.timestamps
    end
    add_index :orders, :reference,      unique: true
    add_index :orders, :status
    add_index :orders, :payment_status
  end
end

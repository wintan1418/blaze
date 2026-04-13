class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :quantity,        default: 1, null: false
      t.integer :unit_price_kobo, default: 0, null: false
      t.string  :name_snapshot                              # preserve name at order time

      t.timestamps
    end
  end
end

class CreateOfflineSales < ActiveRecord::Migration[8.1]
  def change
    create_table :offline_sales do |t|
      t.references :menu_item,   foreign_key: true                          # nullable — custom items allowed
      t.references :location,    foreign_key: true
      t.references :recorded_by, foreign_key: { to_table: :users }, null: false
      t.integer  :quantity,        default: 1, null: false
      t.integer  :unit_price_kobo, default: 0, null: false
      t.integer  :total_kobo,      default: 0, null: false
      t.string   :description                                                # for custom items not on the menu
      t.string   :payment_method,  default: "cash", null: false              # cash / card / transfer / other
      t.text     :notes
      t.datetime :sold_at,         null: false

      t.timestamps
    end
    add_index :offline_sales, :sold_at
    add_index :offline_sales, :payment_method
  end
end

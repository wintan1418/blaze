class CreateSpecials < ActiveRecord::Migration[8.1]
  def change
    create_table :specials do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.text    :description
      t.string  :kind,        null: false, default: "food"  # food / drink / cinema / gaming
      t.integer :price_kobo,         default: 0, null: false
      t.integer :original_price_kobo, default: 0, null: false
      t.integer :slots_total,        default: 20, null: false
      t.integer :slots_claimed,      default: 0,  null: false
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active,      default: true, null: false
      t.string  :image_url
      t.references :location,   foreign_key: true
      t.references :menu_item,  foreign_key: true
      t.references :screening,  foreign_key: true

      t.timestamps
    end
    add_index :specials, :slug, unique: true
    add_index :specials, :active
    add_index :specials, :kind
  end
end

class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.integer :price_kobo, default: 0, null: false
      t.references :menu_category, null: false, foreign_key: true
      t.boolean :available, default: true, null: false
      t.boolean :featured, default: false, null: false
      t.integer :preparation_time

      t.timestamps
    end
    add_index :menu_items, :slug, unique: true
  end
end

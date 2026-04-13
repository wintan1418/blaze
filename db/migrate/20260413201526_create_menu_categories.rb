class CreateMenuCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_categories do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.string :accent_color

      t.timestamps
    end
    add_index :menu_categories, :slug, unique: true
  end
end

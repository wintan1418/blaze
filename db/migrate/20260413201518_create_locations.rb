class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :slug
      t.string :address
      t.string :city
      t.string :phone
      t.boolean :active, default: true, null: false
      t.string :hero_image_url

      t.timestamps
    end
    add_index :locations, :slug, unique: true
  end
end

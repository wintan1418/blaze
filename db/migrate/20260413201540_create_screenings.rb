class CreateScreenings < ActiveRecord::Migration[8.1]
  def change
    create_table :screenings do |t|
      t.string :title
      t.string :slug
      t.text :synopsis
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.references :screen, null: false, foreign_key: true
      t.integer :price_kobo, default: 0, null: false
      t.string :poster_url
      t.boolean :available, default: true, null: false

      t.timestamps
    end
    add_index :screenings, :slug, unique: true
  end
end

class CreateGamingSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :gaming_slots do |t|
      t.references :gaming_console, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, default: 30, null: false
      t.string :status, default: "open", null: false
      t.integer :price_kobo, default: 0, null: false

      t.timestamps
    end
  end
end

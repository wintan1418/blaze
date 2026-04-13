class CreateGamingConsoles < ActiveRecord::Migration[8.1]
  def change
    create_table :gaming_consoles do |t|
      t.integer :number
      t.string :console_type
      t.references :location, null: false, foreign_key: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end

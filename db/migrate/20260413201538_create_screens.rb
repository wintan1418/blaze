class CreateScreens < ActiveRecord::Migration[8.1]
  def change
    create_table :screens do |t|
      t.string :name
      t.integer :capacity
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end

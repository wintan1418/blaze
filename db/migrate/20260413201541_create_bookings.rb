class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :bookable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :seats, default: 1, null: false
      t.integer :total_price_kobo, default: 0, null: false
      t.string :status, default: "pending", null: false
      t.string :reference, null: false
      t.text :notes

      t.timestamps
    end
    add_index :bookings, :reference, unique: true
    add_index :bookings, :status
  end
end

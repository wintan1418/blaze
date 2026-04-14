class CreateLoyaltyStamps < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_stamps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :source, polymorphic: true                   # Booking or Order that earned it
      t.string     :category,   null: false                      # gaming / cinema / food
      t.datetime   :earned_at,  null: false
      t.boolean    :redeemed,   default: false, null: false
      t.datetime   :redeemed_at
      t.references :redeemed_by, foreign_key: { to_table: :users }
      t.string     :redemption_note

      t.timestamps
    end
    add_index :loyalty_stamps, [ :user_id, :category ]
    add_index :loyalty_stamps, :redeemed
  end
end

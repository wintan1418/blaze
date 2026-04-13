class AddStartsAtIndexToGamingSlots < ActiveRecord::Migration[8.1]
  def change
    add_index :gaming_slots, :starts_at
    add_index :gaming_slots, :status
    add_index :screenings, :starts_at
  end
end

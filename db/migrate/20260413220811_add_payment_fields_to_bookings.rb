class AddPaymentFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :payment_status, :string, default: "unpaid", null: false
    add_column :bookings, :paid_at, :datetime
    add_index  :bookings, :payment_status
  end
end

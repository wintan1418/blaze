class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :payable,    polymorphic: true, null: false  # Booking (today), Order (future)
      t.references :user,       null: false, foreign_key: true
      t.string     :reference,  null: false                      # our unique ref sent to Paystack
      t.string     :provider,   default: "paystack", null: false
      t.string     :provider_reference                            # Paystack's own ref (after verification)
      t.integer    :amount_kobo, null: false
      t.string     :currency,   default: "NGN", null: false
      t.string     :status,     default: "pending", null: false   # pending / success / failed / abandoned
      t.string     :channel                                       # card / bank / ussd / mobile_money
      t.datetime   :paid_at
      t.string     :authorization_url
      t.jsonb      :metadata,   default: {}, null: false

      t.timestamps
    end

    add_index :payments, :reference,          unique: true
    add_index :payments, :provider_reference
    add_index :payments, :status
  end
end

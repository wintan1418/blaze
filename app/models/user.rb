class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { customer: 0, staff: 1, admin: 2 }

  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :full_name, presence: true, on: :update, if: -> { will_save_change_to_full_name? }

  def display_name
    full_name.presence || email.split("@").first
  end
end

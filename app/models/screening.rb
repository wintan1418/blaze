class Screening < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :screen
  has_one :location, through: :screen
  has_many :bookings, as: :bookable, dependent: :restrict_with_error
  has_one_attached :poster

  validates :title, :starts_at, presence: true
  validates :price_kobo, numericality: { greater_than_or_equal_to: 0 }

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :available, -> { where(available: true) }

  def seats_remaining
    screen.capacity - bookings.where.not(status: "cancelled").sum(:seats)
  end

  def sold_out?
    seats_remaining <= 0
  end

  def price_naira
    price_kobo.to_i / 100.0
  end
end

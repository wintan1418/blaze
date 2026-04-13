class GamingSlot < ApplicationRecord
  belongs_to :gaming_console
  has_many :bookings, as: :bookable, dependent: :restrict_with_error
  has_one :location, through: :gaming_console

  STATUSES = %w[open reserved blocked].freeze

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :price_kobo, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :available, -> { where(status: "open") }

  def ends_at
    starts_at + duration_minutes.minutes
  end

  def taken?
    status != "open" || bookings.where.not(status: "cancelled").exists?
  end

  def price_naira
    price_kobo.to_i / 100.0
  end
end

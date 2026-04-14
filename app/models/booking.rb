class Booking < ApplicationRecord
  belongs_to :bookable, polymorphic: true
  belongs_to :user
  has_many :payments, as: :payable, dependent: :destroy

  STATUSES = %w[pending confirmed cancelled].freeze
  PAYMENT_STATUSES = %w[unpaid paid refunded].freeze

  validates :seats, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :reference, presence: true, uniqueness: true

  before_validation :generate_reference, on: :create
  before_validation :calculate_total_price, on: :create
  after_create_commit :broadcast_availability

  scope :active, -> { where.not(status: "cancelled") }
  scope :recent, -> { order(created_at: :desc) }
  scope :paid, -> { where(payment_status: "paid") }

  def paid?
    payment_status == "paid"
  end

  def unpaid?
    payment_status == "unpaid"
  end

  # Called after payment success — confirms the booking and fires notifications.
  def mark_paid!(at: Time.current)
    update!(payment_status: "paid", paid_at: at, status: "confirmed")
    NotificationCenter.notify(:booking_confirmed, booking: self)
    award_loyalty_stamp
  end

  def loyalty_category
    case bookable_type
    when "GamingSlot" then "gaming"
    when "Screening"  then "cinema"
    end
  end

  def check_in!
    update!(status: "confirmed", notes: "#{notes} [checked in #{Time.current.strftime('%I:%M %p')}]".strip)
  end

  def cancel!
    update!(status: "cancelled")
    NotificationCenter.notify(:booking_cancelled, booking: self)
  end

  def total_price_naira
    total_price_kobo.to_i / 100.0
  end

  private

  def generate_reference
    return if reference.present?
    loop do
      self.reference = "BLZ-#{SecureRandom.alphanumeric(8).upcase}"
      break unless Booking.exists?(reference: reference)
    end
  end

  def calculate_total_price
    return if total_price_kobo.to_i > 0
    self.total_price_kobo = seats.to_i * bookable.price_kobo.to_i
  end

  def broadcast_availability
    return unless bookable.is_a?(GamingSlot)
    Turbo::StreamsChannel.broadcast_replace_to(
      "gaming_slots",
      target: "gaming_slot_#{bookable_id}",
      partial: "gaming_slots/slot",
      locals: { slot: bookable }
    )
  rescue StandardError
    # Broadcasting is best-effort; never block booking creation on it
  end

  def award_loyalty_stamp
    category = loyalty_category
    return unless category
    LoyaltyStamp.award_for!(user: user, source: self, category: category, earned_at: paid_at || Time.current)
  rescue StandardError => e
    Rails.logger.warn("[LoyaltyStamp] award failed: #{e.message}")
  end
end

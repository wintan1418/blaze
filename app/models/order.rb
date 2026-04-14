class Order < ApplicationRecord
  belongs_to :user
  belongs_to :location, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true

  STATUSES = %w[pending preparing ready completed cancelled].freeze
  PAYMENT_STATUSES = %w[unpaid paid refunded].freeze
  FULFILLMENT_TYPES = %w[pickup dine_in delivery].freeze
  DELIVERY_STATUSES = %w[none pending dispatched delivered failed].freeze

  validates :reference, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :fulfillment, inclusion: { in: FULFILLMENT_TYPES }
  validates :delivery_status, inclusion: { in: DELIVERY_STATUSES }
  validates :total_kobo, numericality: { greater_than_or_equal_to: 0 }

  with_options if: :delivery? do
    validates :delivery_address, :delivery_phone, :delivery_city, presence: true
  end

  before_validation :generate_reference, on: :create
  before_validation :set_delivery_status_default
  before_save :recalculate_total

  scope :recent, -> { order(created_at: :desc) }
  scope :paid, -> { where(payment_status: "paid") }
  scope :active, -> { where.not(status: "cancelled") }
  scope :for_delivery, -> { where(fulfillment: "delivery") }

  def paid?
    payment_status == "paid"
  end

  def delivery?
    fulfillment == "delivery"
  end

  def pickup?
    fulfillment == "pickup"
  end

  def item_count
    order_items.sum(:quantity)
  end

  def mark_paid!(at: Time.current)
    update!(payment_status: "paid", paid_at: at, status: "preparing")
    self.update!(delivery_status: "pending") if delivery? && delivery_status == "none"
    NotificationCenter.notify(:order_paid, order: self)
    award_food_stamp
  end

  def advance_status!
    next_status = case status
    when "pending"   then "preparing"
    when "preparing" then "ready"
    when "ready"     then "completed"
    end
    return unless next_status

    update!(status: next_status)
    NotificationCenter.notify(:order_ready, order: self) if next_status == "ready"
  end

  def mark_dispatched!
    update!(delivery_status: "dispatched", dispatched_at: Time.current)
    NotificationCenter.notify(:order_out_for_delivery, order: self)
  end

  def mark_delivered!
    update!(delivery_status: "delivered", delivered_at: Time.current, status: "completed")
    NotificationCenter.notify(:order_delivered, order: self)
  end

  # Sums up item subtotals. Called before_save.
  def recalculate_total
    self.subtotal_kobo = order_items
      .reject(&:marked_for_destruction?)
      .sum { |oi| oi.quantity.to_i * oi.unit_price_kobo.to_i }
    self.total_kobo = subtotal_kobo + delivery_fee_kobo.to_i
  end

  private

  def generate_reference
    return if reference.present?
    loop do
      self.reference = "BLZ-ORD-#{SecureRandom.alphanumeric(8).upcase}"
      break unless Order.exists?(reference: reference)
    end
  end

  def set_delivery_status_default
    self.delivery_status = delivery? ? "pending" : "none" if delivery_status.blank?
  end

  def award_food_stamp
    LoyaltyStamp.award_for!(user: user, source: self, category: "food", earned_at: paid_at || Time.current)
  rescue StandardError => e
    Rails.logger.warn("[LoyaltyStamp] food award failed: #{e.message}")
  end
end

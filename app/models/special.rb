class Special < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :location,   optional: true
  belongs_to :menu_item,  optional: true
  belongs_to :screening,  optional: true
  has_one_attached :image

  KINDS = %w[food drink cinema gaming].freeze

  validates :name, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :slots_total,   numericality: { greater_than_or_equal_to: 0 }
  validates :slots_claimed, numericality: { greater_than_or_equal_to: 0 }
  validates :price_kobo, numericality: { greater_than_or_equal_to: 0 }

  scope :active,   -> { where(active: true) }
  scope :live_now, -> {
    now = Time.current
    active.where("(starts_at IS NULL OR starts_at <= ?) AND (ends_at IS NULL OR ends_at >= ?)", now, now)
  }
  scope :ordered,  -> { order(:starts_at, :id) }

  def slots_remaining
    [ slots_total.to_i - slots_claimed.to_i, 0 ].max
  end

  def sold_out?
    slots_remaining <= 0
  end

  def claim_percentage
    return 0 if slots_total.to_i.zero?
    ((slots_claimed.to_f / slots_total) * 100).round.clamp(0, 100)
  end

  def discount_percentage
    return 0 if original_price_kobo.to_i.zero? || price_kobo.to_i >= original_price_kobo.to_i
    (((original_price_kobo - price_kobo).to_f / original_price_kobo) * 100).round
  end

  def image_src
    return Rails.application.routes.url_helpers.url_for(image) if image.attached?
    image_url
  end

  def live?
    active? &&
      (starts_at.nil? || starts_at <= Time.current) &&
      (ends_at.nil?   || ends_at   >= Time.current) &&
      !sold_out?
  end

  def time_window_label
    parts = []
    parts << "from #{starts_at.strftime('%I:%M %p')}" if starts_at
    parts << "until #{ends_at.strftime('%I:%M %p')}" if ends_at
    parts.any? ? parts.join(" ") : "today only"
  end

  def claim!
    with_lock do
      raise "Sold out" if sold_out?
      update!(slots_claimed: slots_claimed + 1)
    end
  end
end

class OfflineSale < ApplicationRecord
  belongs_to :menu_item, optional: true
  belongs_to :location,  optional: true
  belongs_to :recorded_by, class_name: "User"

  PAYMENT_METHODS = %w[cash card transfer pos other].freeze

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_kobo, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validates :sold_at, presence: true
  validate  :menu_item_or_description_present

  before_save :snapshot_from_menu_item
  before_save :calculate_total

  scope :recent, -> { order(sold_at: :desc) }
  scope :for_day,   ->(date) { where(sold_at: date.beginning_of_day..date.end_of_day) }
  scope :for_range, ->(range) { where(sold_at: range) }

  def label
    menu_item&.name || description || "Custom item"
  end

  private

  def snapshot_from_menu_item
    return unless menu_item
    self.unit_price_kobo = menu_item.price_kobo if unit_price_kobo.to_i.zero?
    self.description     = menu_item.name if description.blank?
  end

  def calculate_total
    self.total_kobo = quantity.to_i * unit_price_kobo.to_i
  end

  def menu_item_or_description_present
    return if menu_item_id.present? || description.present?
    errors.add(:base, "Pick a menu item or enter a description")
  end
end

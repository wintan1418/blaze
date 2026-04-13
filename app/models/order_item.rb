class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :menu_item

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_kobo, numericality: { greater_than_or_equal_to: 0 }

  before_validation :snapshot_price_and_name, on: :create

  def subtotal_kobo
    quantity.to_i * unit_price_kobo.to_i
  end

  private

  def snapshot_price_and_name
    return unless menu_item
    self.unit_price_kobo = menu_item.price_kobo if unit_price_kobo.to_i.zero?
    self.name_snapshot   = menu_item.name if name_snapshot.blank?
  end
end

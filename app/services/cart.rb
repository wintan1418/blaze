require "delegate"

# Session-backed shopping cart. Stores { menu_item_id => quantity }
# in the Rails session and rehydrates MenuItem records on read.
#
# Usage from controllers:
#   cart = Cart.new(session)
#   cart.add(menu_item, qty: 2)
#   cart.items  # => Array of CartLine
#   cart.total_kobo
class Cart
  SESSION_KEY = "blaze_cart".freeze

  CartLine = Struct.new(:menu_item, :quantity, keyword_init: true) do
    def subtotal_kobo
      quantity.to_i * menu_item.price_kobo.to_i
    end
  end

  attr_reader :session

  def initialize(session)
    @session = session
    session[SESSION_KEY] ||= {}
  end

  def data
    session[SESSION_KEY]
  end

  def add(menu_item, qty: 1)
    return unless menu_item && menu_item.available?
    key = menu_item.id.to_s
    data[key] = (data[key].to_i + qty.to_i).clamp(1, 99)
  end

  def set(menu_item_id, qty)
    key = menu_item_id.to_s
    q = qty.to_i.clamp(0, 99)
    if q.zero?
      data.delete(key)
    else
      data[key] = q
    end
  end

  def remove(menu_item_id)
    data.delete(menu_item_id.to_s)
  end

  def clear!
    session[SESSION_KEY] = {}
  end

  def empty?
    data.empty?
  end

  def total_items
    data.values.sum
  end

  def items
    return [] if data.empty?
    ids = data.keys.map(&:to_i)
    MenuItem.where(id: ids).available.includes(:menu_category, image_attachment: :blob).map do |mi|
      CartLine.new(menu_item: mi, quantity: data[mi.id.to_s].to_i)
    end
  end

  def total_kobo
    items.sum(&:subtotal_kobo)
  end
end

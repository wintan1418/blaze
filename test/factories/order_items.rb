FactoryBot.define do
  factory :order_item do
    order { nil }
    menu_item { nil }
    quantity { 1 }
    unit_price_kobo { 1 }
  end
end

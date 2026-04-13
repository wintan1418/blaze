FactoryBot.define do
  factory :offline_sale do
    menu_item { nil }
    location { nil }
    recorded_by { nil }
    quantity { 1 }
    unit_price_kobo { 1 }
    total_kobo { 1 }
    description { "MyString" }
    payment_method { "MyString" }
    notes { "MyText" }
    sold_at { "2026-04-13 23:58:29" }
  end
end

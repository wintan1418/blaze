FactoryBot.define do
  factory :special do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    kind { "MyString" }
    price_kobo { 1 }
    original_price_kobo { 1 }
    slots_total { 1 }
    slots_claimed { 1 }
    starts_at { "2026-04-14 12:44:14" }
    ends_at { "2026-04-14 12:44:14" }
    active { false }
    location { nil }
    menu_item { nil }
    screening { nil }
  end
end

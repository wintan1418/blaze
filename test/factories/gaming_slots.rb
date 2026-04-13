FactoryBot.define do
  factory :gaming_slot do
    gaming_console { nil }
    starts_at { "2026-04-13 21:15:30" }
    duration_minutes { 1 }
    status { "MyString" }
    price_kobo { 1 }
  end
end

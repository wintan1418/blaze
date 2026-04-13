FactoryBot.define do
  factory :screening do
    title { "MyString" }
    slug { "MyString" }
    synopsis { "MyText" }
    starts_at { "2026-04-13 21:15:40" }
    ends_at { "2026-04-13 21:15:40" }
    screen { nil }
    price_kobo { 1 }
    poster_url { "MyString" }
    available { false }
  end
end

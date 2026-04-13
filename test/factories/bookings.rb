FactoryBot.define do
  factory :booking do
    bookable { nil }
    user { nil }
    seats { 1 }
    total_price_kobo { 1 }
    status { "MyString" }
    reference { "MyString" }
    notes { "MyText" }
  end
end

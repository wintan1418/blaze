FactoryBot.define do
  factory :order do
    user { nil }
    location { nil }
    reference { "MyString" }
    status { "MyString" }
    payment_status { "MyString" }
    fulfillment { "MyString" }
    total_kobo { 1 }
    notes { "MyText" }
  end
end

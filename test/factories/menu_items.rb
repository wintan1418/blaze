FactoryBot.define do
  factory :menu_item do
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    price_kobo { 1 }
    menu_category { nil }
    available { false }
    featured { false }
    preparation_time { 1 }
  end
end

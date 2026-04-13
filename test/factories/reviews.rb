FactoryBot.define do
  factory :review do
    reviewable { nil }
    user { nil }
    rating { 1 }
    body { "MyText" }
  end
end

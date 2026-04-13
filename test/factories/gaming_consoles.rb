FactoryBot.define do
  factory :gaming_console do
    number { 1 }
    console_type { "MyString" }
    location { nil }
    active { false }
  end
end

# FactoryBot.define do
#   factory :stock do
#     sequence(:symbol) { |n| "STK#{n}" }
#     sequence(:name)   { |n| "Stock #{n} Inc." }
#     last_price { 150.0 }
#   end
# end

# create(:stock, symbol: "AAPL", name: "Apple Inc.") - override
# spec/factories/stocks.rb
FactoryBot.define do
  factory :stock do
    sequence(:symbol) { |n| "STK#{n}" }
    sequence(:name) { |n| "Stock #{n} Inc." }
    last_price { 150.0 }

    trait :without_price do
      last_price { nil }
    end
  end
end
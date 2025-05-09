# # spec/factories/transactions.rb
# FactoryBot.define do
#   factory :transaction do
#     transaction_type { 'buy' } # Default value
#     quantity { 10 }
#     buy_price { 100.00 }
#     total_amount { 1000.00 }
#     transaction_date { Date.today }
#     symbol { 'AAPL' }
#     user
#     holding
#   end
# end
# 
# spec/factories/transactions.rb
# spec/factories/transactions.rb
FactoryBot.define do
  factory :transaction do
    association :user
    transaction_type { 'buy' }
    quantity { 10 }
    buy_price { 100.00 }
    total_amount { 1000.00 }
    transaction_date { Date.today }
    symbol { 'AAPL' }
    holding { nil }

    trait :buy do
      holding { association(:holding) }
    end

    trait :sell do
      transaction_type { 'sell' }
      holding { association(:holding) }
    end

    trait :deposit do
      transaction_type { 'deposit' }
      quantity { nil }
      buy_price { nil }
      holding { nil }
    end
  end
end
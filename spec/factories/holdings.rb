# FactoryBot.define do
#   factory :holding do
#     association :portfolio
#     association :stock
#     shares { 10 }

#     after(:build) do |holding|
#       holding.total ||= holding.shares * holding.stock.last_price
#     end
#   end
# end

# create(:holding, shares: 20, average_price: 150.0) - override
# 
# spec/factories/holdings.rb
# spec/factories/holdings.rb
FactoryBot.define do
  factory :holding do
    association :portfolio
    association :stock
    shares { 10 }
    
    after(:build) do |holding|
      holding.total ||= holding.shares * holding.stock.last_price
    end
  end
end
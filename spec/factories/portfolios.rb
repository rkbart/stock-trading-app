# # spec/factories/portfolios.rb
# FactoryBot.define do
#   factory :portfolio do
#     association :user
#     balance { 0.0 }
#     total_value { 0.0 } # Added to match your override example

#     trait :with_value do
#       total_value { 1000.0 }
#     end
#   end
# end
# spec/factories/portfolios.rb
FactoryBot.define do
  factory :portfolio do
    association :user
    balance { 0.0 } # Remove total_value since it's not in your schema
  end
end
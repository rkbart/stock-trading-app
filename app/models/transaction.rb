class Transaction < ApplicationRecord
  belongs_to :stock
  belongs_to :holding

  enum :transaction_type, { buy: 0, sell: 1 }
end

class Transaction < ApplicationRecord
  belongs_to :user
  # scope :for_portfolio, ->(portfolio_id) { joins(holding: :portfolio).where(holdings: { portfolio_id: portfolio_id }) }
  scope :recent_first, -> { order(transaction_date: :desc) }

  enum :transaction_type, { buy: 0, sell: 1 }
end

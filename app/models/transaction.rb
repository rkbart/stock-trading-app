class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :holding, optional: true
  scope :recent_first, -> { order(transaction_date: :desc, id: :desc) }

  enum :transaction_type, { buy: 0, sell: 1, deposit: 2 }
  validates :total_amount, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0 }, if: :requires_quantity? # for deposit

  def requires_quantity?
    transaction_type.in?([ "buy", "sell" ])
  end
end

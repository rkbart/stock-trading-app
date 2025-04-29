class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock
  has_many :transactions, dependent: :destroy

  scope :with_shares, -> { where("shares > 0") }
  scope :by_symbol, -> { joins(:stock).order("stocks.symbol") }

  def value
    shares * stock.current_price
  end
end

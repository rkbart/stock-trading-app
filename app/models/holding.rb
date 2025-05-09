class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock
  has_many :transactions, dependent: :destroy

  def value
    shares * stock.current_price # stocks model
  end

  def average_price
    return 0 if shares.zero?
    total / shares
  end
end

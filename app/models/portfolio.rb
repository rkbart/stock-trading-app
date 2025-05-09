class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :holdings, dependent: :destroy

  def total_value
    holdings.includes(:stock).sum(&:value) # holding model value (share * stocks.current_price)(current_price = stocks.last_price)
  end
end

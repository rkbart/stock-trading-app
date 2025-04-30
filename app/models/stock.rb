class Stock < ApplicationRecord
  has_many :holdings

  # scope :with_price, -> { where.not(last_price: nil) }

  def current_price
    last_price || 0
  end
end

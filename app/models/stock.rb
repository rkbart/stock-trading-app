class Stock < ApplicationRecord
  has_many :holdings

  def current_price
    last_price || 0
  end
end

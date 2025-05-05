class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :holdings, dependent: :destroy

  def total_value
    holdings.includes(:stock).sum(&:value)
  end
end

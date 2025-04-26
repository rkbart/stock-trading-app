class Holding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock
  has_many :transactions, dependent: :destroy
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_one :portfolio, dependent: :destroy
  after_create :create_potfolio

  enum :role, { trader: 0, admin: 1 }

  validates :status, inclusion: { in: %w[pending approved rejected] }

  def balance
    portfolio&.balance || 0
  end

 private

  def create_potfolio
    Portfolio.create!(user_id: self.id, balance: 0.0)
  end

  # user.trader?  # true if role is trader
  # user.admin?   # true if role is admin
  # user.status == "approved"
end

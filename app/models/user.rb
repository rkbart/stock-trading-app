class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable
  extend FriendlyId
  friendly_id :full_name, use: :slugged

  has_one :portfolio, dependent: :destroy
  has_many :transactions, dependent: :destroy

  after_create :create_portfolio

  enum :role, { trader: 0, admin: 1 }

  validates :status, inclusion: { in: %w[pending approved rejected] }

  def balance
    portfolio&.balance || 0
  end

  def full_name
    "#{email.split('@').first}-#{last_name}".parameterize
  end

  private

  def create_portfolio
    Portfolio.create!(user_id: self.id, balance: 0.0)
  end
end

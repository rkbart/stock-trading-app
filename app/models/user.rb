class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_one :portfolio, dependent: :destroy
  has_many :transactions, dependent: :destroy

  after_create :create_potfolio

  enum :role, { trader: 0, admin: 1 }

  validates :status, inclusion: { in: %w[pending approved rejected] }
  validates :first_name, :last_name, :birthday, :gender, :address, presence: true, on: :update


  def balance
    portfolio&.balance || 0
  end

 private

  def create_potfolio
    Portfolio.create!(user_id: self.id, balance: 0.0)
  end
end

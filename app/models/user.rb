class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :portfolio, dependent: :destroy
  after_create :create_potfolio

  enum :role, { trader: 0, admin: 1 }

  validates :status, inclusion: { in: %w[pending approved rejected] }

  private

  def create_potfolio
    Portfolio.create!(user_id: self.id, balance: 0.0)
  end

  # user.trader?  # true if role is trader
  # user.admin?   # true if role is admin
  # user.status == "approved"
end

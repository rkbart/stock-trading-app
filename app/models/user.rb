class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :portfolios

  enum :role, { trader: 0, admin: 1 }

  validates :status, inclusion: { in: %w[pending approved rejected] }

  # user.trader?  # true if role is trader
  # user.admin?   # true if role is admin
  # user.status == "approved"
end

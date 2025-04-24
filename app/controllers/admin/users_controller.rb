class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @pending_users = User.trader.where(status: "pending")
  end

  def approve
    user = User.find(params[:id])
    if user.update(status: "approved")
      redirect_to admin_users_path, notice: "#{user.email} has been approved."
    else
      redirect_to admin_users_path, alert: "Could not approve user."
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end
end

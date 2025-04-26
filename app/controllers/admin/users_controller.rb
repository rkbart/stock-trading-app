class Admin::UsersController < ApplicationController
  before_action :require_admin

  def index
    @pending_users = User.trader.where(status: "pending")
  end

  def approve
    user = User.find(params[:id])
    if user.update(status: "approved", confirmed_at: Time.now)
      redirect_to admin_users_path, notice: "#{user.email} has been approved."
      UserMailer.with(user: user).welcome_email.deliver_now
    else
      redirect_to admin_users_path, alert: "Could not approve user."
    end
  end

  def reject
    user = User.find(params[:id])
    if user.update(status: "rejected")
      redirect_to admin_users_path, notice: "#{user.email} has been rejected."
      UserMailer.with(user: user).rejection_email.deliver_now
      # user.destroy
    else
      redirect_to admin_users_path, alert: "Could not reject user."
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end
end

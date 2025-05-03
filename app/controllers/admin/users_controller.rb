class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_user_in_admin, only: %i[show change_role edit update approve reject]

  def index
    @pending_users = User.trader.where(status: "pending")
  end

  def approve
    # user = User.find(params[:id])
    if @user.update!(status: "approved", confirmed_at: Time.now)
      redirect_to admin_users_path, notice: "#{@user.email} has been approved."
      UserMailer.with(user: @user).welcome_email.deliver_now
    else
      redirect_to admin_users_path, alert: "Could not approve user."
    end
  end

  def reject
    # user = User.find(params[:id])
    if @user.update(status: "rejected")
      redirect_to admin_users_path, notice: "#{@user.email} has been rejected."
      UserMailer.with(user: @user).rejection_email.deliver_now
      # user.destroy
    else
      redirect_to admin_users_path, alert: "Could not reject user."
    end
  end

  def show_all_traders
    @list_of_traders = User.trader.all
  end

  def show
    if @user.first_name.blank? || @user.last_name.blank? || @user.birthday.blank? || @user.gender.blank? || @user.address.blank?
      redirect_to show_all_traders_admin_users_path, alert: "Trader hasn't completed their profile yet."
    end
  end

  def invite_trader; end

  def send_invite
    email = params[:email]

    if email.present?
      user = User.find_by(email: email)

      unless user
        user = User.create!(
          email: email,
          password: "password123",
          role: "trader",
          status: "approved",
          confirmed_at: Time.now
        )
      end

      UserMailer.with(user: user).invitation_email.deliver_now

      flash[:notice] = "Invitation sent to #{email}."
      redirect_to admin_user_path(user)
    else
      render :invite_trader, aler: "Please enter a valid email."
    end
  end

  def all_transactions
    @all_transactions = Transaction.all
  end

  def change_role
    if @user.update(role: params[:user][:role])
      redirect_to user_path(@user), notice: "User role updated successfully."
    else
      redirect_to user_path(@user), alert: "Failed to update role."
    end
  end

  def edit; end

  def update
    if @user.update(edit_user_params)
      redirect_to admin_user_path(@user), notice: "Trader profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end

  def set_user_in_admin
    @user = User.find(params[:id])
  end

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :address, :role)
  end
end

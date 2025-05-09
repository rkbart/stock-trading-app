class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_user_in_admin, only: %i[show edit update approve reject]

  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found
  def index
    @pending_users = User.trader.where(status: "pending") # enum role
  end

  def approve
    if @manage_user.update(status: "approved", confirmed_at: Time.now)
      UserMailer.with(user: @manage_user).welcome_email.deliver_now
      redirect_to admin_users_path, notice: "#{@manage_user.email} has been approved."
    else
      redirect_to admin_users_path, alert: "Could not approve user."
    end
  end

  def reject
    if @manage_user.update(status: "rejected")
      UserMailer.with(user: @manage_user).rejection_email.deliver_now
      @manage_user.destroy
      redirect_to admin_users_path, notice: "#{@manage_user.email} has been rejected."
    else
      redirect_to admin_users_path, alert: "Could not reject user."
    end
  end

  def show_all_traders
    @list_of_traders = User.trader.all
  end

  def show
    if @manage_user.first_name.blank? || @manage_user.last_name.blank? || @manage_user.birthday.blank? || @manage_user.gender.blank? || @manage_user.address.blank?
      redirect_to show_all_traders_admin_users_path, alert: "Could not show information. Trader hasn't completed their profile yet."
    end

    @user_transactions = Transaction.where(user_id: @manage_user.id)
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

      redirect_to admin_user_path(user), notice: "Invitation sent to #{email}."
    else
      render :invite_trader, alert: "Please enter a valid email."
    end
  end

  def all_transactions
    @all_transactions = Transaction.all
  end


  def edit; end

  def update
    if @manage_user.update(edit_user_params)
      redirect_to admin_user_path(@manage_user), notice: "Trader profile updated successfully."
    else
      flash.now[:alert] = "Could not update trader profile."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end

  def set_user_in_admin
    @manage_user = User.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @manage_user = User.find(params[:id])
  end

  def user_not_found
    redirect_to show_all_traders_admin_users_path, alert: "User not found."
  end

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :address, :role)
  end
end

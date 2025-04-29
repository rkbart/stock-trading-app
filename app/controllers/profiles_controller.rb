class ProfilesController < ApplicationController
  def edit; end
  def show; end

  def update
    # @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :address)
  end
end

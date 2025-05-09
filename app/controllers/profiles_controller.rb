class ProfilesController < TradersController
  def edit; end
  def show
    if @user.first_name.blank? || @user.last_name.blank? || @user.birthday.blank? || @user.gender.blank? || @user.address.blank?
      redirect_to edit_profile_path, alert: "You haven't completed your profile yet."
    end
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :address)
  end
end

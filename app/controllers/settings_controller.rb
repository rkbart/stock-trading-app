class SettingsController < ApplicationController
  def show
  end

  def change_role
    if @user.update(role: params[:user][:role])
      redirect_to root_path, notice: "User role updated successfully."
    else
      redirect_to settings_path, alert: "Failed to update role."
    end
  end
end

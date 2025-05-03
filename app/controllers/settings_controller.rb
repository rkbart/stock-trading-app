class SettingsController < ApplicationController
  def show; end

  def update_role
    if @user.update(role: params[:user][:role])
      redirect_to root_path, notice: "User role updated successfully."
    else
      redirect_to settings_update_role_path, alert: "Failed to update role."
    end
  end
end

class SettingsController < TradersController
  def show; end

  def update_role
     new_role = params[:user][:role]

    if @user.role == new_role
      redirect_to settings_update_role_path, alert: "No changes detected. User already has the '#{new_role}' role."
    elsif @user.update(role: new_role)
      redirect_to root_path, notice: "User role updated successfully."
    else
      redirect_to settings_update_role_path, alert: "Failed to update role."
    end
  end
end

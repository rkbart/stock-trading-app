class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  # before_action :ensure_trader!

  # def ensure_trader! #scope
  #   redirect_to pages_dashboard_path unless current_user.trader?
  # end

  # After Devise sign in
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_users_path
    else
      pages_dashboard_path
    end
  end


  # After Devise sign up
  def after_sign_up_path_for(resource)
    pages_dashboard_path
  end
end

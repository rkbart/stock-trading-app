class ErrorsController < ApplicationController
  def not_found
    if user_signed_in?
      if current_user.admin?
        redirect_to home_path, alert: "Page not found. Redirected to admin home."
      else
        redirect_to root_path, alert: "Page not found. Redirected to dashboard."
      end
      # else
      #   render "errors/not_found", status: :not_found
    end
  end
end

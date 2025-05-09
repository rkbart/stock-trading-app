class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user
  before_action :set_portfolio,  if: -> { @user&.trader? }

  def after_sign_in_path_for(resource)
    if resource.admin?
      home_path
    else
      if resource.first_name.blank? || resource.last_name.blank?
        edit_profile_path
      else
        super # default devise redirect
      end
    end
  end

  def fetch_api_response(symbol)
    cache_key = "stock_api_response_#{symbol}_#{Date.today}"

    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      AvaApi.fetch_records(symbol)
    rescue StandardError => e
      Rails.logger.error("API fetch failed for #{symbol}: #{e.message}")
      nil
    end
  end

  private

  def set_portfolio
    @portfolio = @user.portfolio
    @balance = @portfolio&.balance || 0
  end

  def set_user
    @user = current_user
  end

  def require_trader!
    unless @user&.trader?
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end

  protected

  def configure_permitted_parameters
    added_attrs = [ :first_name, :last_name, :birthday, :gender, :address ]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end
end

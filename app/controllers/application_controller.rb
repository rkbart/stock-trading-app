class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_portfolio,  if: -> { current_user&.trader? }
  before_action :set_holdings, if: -> { current_user&.trader? }
  before_action :set_user

  # After Devise sign in
  def after_sign_in_path_for(resource)
    if resource.admin?
      home_path
    else
      if resource.first_name.blank? || resource.last_name.blank?
        edit_profile_path
      else
        super
      end
    end
  end

  def fetch_api_response(symbol)
    cache_key = "stock_api_response_#{symbol}_#{Date.today}"

    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      begin
        AvaApi.fetch_records(symbol)
      rescue StandardError => e
        Rails.logger.error("API fetch failed for #{symbol}: #{e.message}")
        nil
      end
    end
  end


  private

  def set_portfolio
    @portfolio = current_user.portfolio
    @balance = @portfolio&.balance || 0
  end

  def set_holdings
    @holdings = @portfolio.holdings.includes(:stock).with_shares # scope where shares > 0
    # @holdings = @portfolio.holdings.includes(:stock).with_shares.by_symbol # alphabetical sorting
    @total_holdings_value = @holdings.sum { |holding| holding.value }
  end

  def set_user
    @user = current_user
  end

  protected

  def configure_permitted_parameters
    added_attrs = [ :first_name, :last_name, :birthday, :gender, :address ]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end
end

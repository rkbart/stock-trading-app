class SellsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_holdings, only: %i[new create]
  before_action :set_variables

  def new
    @stocks = Stock.all
    @selected_price = nil
    @max_quantity = nil

    return unless @selected_symbol.present?

    holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }

    if holding
      @max_quantity = holding.shares
      @selected_price = fetch_cached_price(@selected_symbol, holding.stock.last_price)
    else
      redirect_to portfolios_path, alert: "Stock not found in your portfolio"
    end
  end

  def create
    quantity = params[:quantity].to_i
    holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }

    unless holding
      redirect_to portfolios_path, alert: "Stock not found in your portfolio"
      return
    end

    price = fetch_cached_price(@selected_symbol, holding.stock.last_price)
    total_amount = price * quantity

    # Update portfolio balance
    portfolio = @user.portfolio
    portfolio.update!(balance: portfolio.balance + total_amount)

    # Update holding
    holding.update!(
      shares: holding.shares - quantity,
      total: holding.total - total_amount
    )

    # Record the transaction
    Transaction.create!(
      user: @user,
      transaction_type: :sell,
      symbol: @selected_symbol,
      quantity: quantity,
      buy_price: price,
      total_amount: total_amount,
      transaction_date: Date.today
    )

    redirect_to portfolios_path, notice: "Successfully sold #{quantity} shares of #{@selected_symbol} for #{number_to_currency(total_amount)}."
  end

  private

  def set_holdings
    @holdings = current_user.portfolio.holdings.includes(:stock)
    @total_holdings = @holdings.sum(&:total)
  end

  def set_variables
    # @user = current_user
    @selected_symbol = params[:symbol]
  end

  # 📦 Fetch and cache API price for a symbol
  def fetch_cached_price(symbol, fallback_price = 0)
    cache_key = "close_price_#{symbol}_#{Date.today}"

    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      response = AvaApi.fetch_records(symbol)

      if response && response["Meta Data"] && response["Time Series (Daily)"]
        response["Time Series (Daily)"].values.first["4. close"].to_f
      else
        Rails.logger.error("Failed to fetch close price for #{symbol}: #{response.inspect}")
        fallback_price || 0
      end
    end
  end
end

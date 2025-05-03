class SellsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_holdings, only: %i[new create]
  before_action :set_variables

  def new
    symbol = params[:symbol]
    stock = Stock.find_by(symbol: symbol)
    holding = @user.portfolio.holdings.find_by(stock: stock)

    @selected_symbol = symbol
    @max_quantity = holding&.shares || 0
  end

  def create
    quantity = params[:quantity].to_i
    holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }

    unless holding
      redirect_to portfolios_path, alert: "Stock not found in your portfolio"
      return
    end

    price = @selected_price
    total_amount = price * quantity

    portfolio = @user.portfolio
    portfolio.update!(balance: portfolio.balance + total_amount)

    holding.update!(
      shares: holding.shares - quantity,
      total: holding.total - total_amount
    )

    Transaction.create!(
      user: @user,
      transaction_type: :sell,
      symbol: @selected_symbol,
      quantity: quantity,
      buy_price: @selected_price,
      total_amount: total_amount,
      transaction_date: Date.today
    )

    redirect_to portfolios_path, notice: quantity == 1 ? "Successfully sold 1 share of #{@selected_symbol} for #{number_to_currency(total_amount)}." : "Successfully sold #{quantity} shares of #{@selected_symbol} for #{number_to_currency(total_amount)}."
  end

  private

  def set_holdings
    @holdings = current_user.portfolio.holdings.includes(:stock)
    @total_holdings = @holdings.sum(&:total)
  end

  def set_variables
    @selected_symbol = params[:symbol]
    @selected_price = fetch_cached_price(@selected_symbol, "4. close")
  end

  def fetch_cached_price(symbol, price_key)
    response = fetch_api_response(symbol)

    if response && response["Time Series (Daily)"]
      response["Time Series (Daily)"].values.first[price_key].to_f
    else
      Rails.logger.error("Failed to fetch #{price_key} for #{symbol}: #{response.inspect}")
      stock = Stock.find_by(symbol: symbol)
      stock&.last_price || 0
    end
  end
end

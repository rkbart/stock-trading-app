class SellsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_holdings, only: %i[new create]
  def new
    @stocks = Stock.all
    @selected_symbol = params[:symbol]
    @selected_price = nil
    @max_quantity = nil

    if @selected_symbol.present?
      holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }

      if holding
        @max_quantity = holding.shares

        # Get the price from cache or API
        cache_key = "close_price_#{@selected_symbol}_#{Date.today}"

        @selected_price = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
          response = AvaApi.fetch_records(@selected_symbol)

          if response && response["Meta Data"] && response["Time Series (Daily)"]
            response["Time Series (Daily)"].values.first["4. close"].to_f
          else
            Rails.logger.error("Failed to fetch close price for #{@selected_symbol}: #{response.inspect}")
            holding.stock.last_price || 0  # fallback if API fails
          end
        end
      else
        redirect_to portfolios_path, alert: "Stock not found in your portfolio"
      end
    end
  end

  def create
    # Get parameters
    symbol = params[:symbol]
    quantity = params[:quantity].to_i
    sell_price = params[:price].to_f
    total_amount = sell_price * quantity
    portfolio = current_user.portfolio # try @user.portfolio

    # Validations
    if symbol.blank? || quantity <= 0 || sell_price <= 0
      flash[:alert] = "Invalid sell request."
      redirect_to new_with_symbol_sells_path(symbol: symbol) and return
    end

    # Find the holding by stock symbol
    holding = portfolio.holdings.joins(:stock).find_by(stocks: { symbol: symbol })
    unless holding
      flash[:alert] = "Holding not found."
      redirect_to sell_stocks_path and return
    end

    # Check if user has enough shares
    if holding.shares < quantity
      flash[:alert] = "You don't have enough shares to sell."
      redirect_to sell_stocks_path(symbol: symbol) and return
    end

    stock = holding.stock # belongs to stock table

    begin
      # Process the sale
      ActiveRecord::Base.transaction do
        # Update portfolio balance
        portfolio.update!(balance: portfolio.balance + total_amount)

        # Update holdings
        holding.update!(shares: holding.shares - quantity)

        # Record the transaction
        Transaction.create!(
          holding_id: holding.id,
          stock_id: stock.id,
          transaction_type: :sell,
          quantity: quantity,
          buy_price: sell_price,
          total_amount: total_amount,
          transaction_date: Date.today
        )
      end

      redirect_to portfolios_path, notice: "Successfully sold #{quantity} shares of #{symbol} for $#{number_with_precision(total_amount, precision: 2, delimiter: ',')}."

    rescue => e
      redirect_to new_sell_path(symbol: symbol), alert: "Sale failed: #{e.message}"
    end
  end

  def set_holdings
    @holdings = current_user.portfolio.holdings.includes(:stock)
    @total_holdings = @holdings.sum { |holding| holding.total }
  end
end

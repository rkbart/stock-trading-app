class BuysController < ApplicationController
  before_action :set_variables
  before_action :set_balance

  def new
    @stocks = Stock.all
    @selected_price = nil
    @max_quantity = nil

    if @selected_symbol.present?
      stock = Stock.find_by(symbol: @selected_symbol)

      if stock
        @selected_price = fetch_cached_price(@selected_symbol, "1. open")
        @max_quantity = (@balance / @selected_price).floor if @selected_price.to_f.positive?
      else
        redirect_to new_buy_path, alert: "Stock not found." and return
      end
    end
  end

  def create
    portfolio = @user.portfolio
    price = fetch_cached_price(@selected_symbol, "1. open")
    quantity = params[:quantity].to_i
    total_cost = price * quantity
    stock = Stock.find_by(symbol: @selected_symbol)

    if portfolio.balance < total_cost
      redirect_to new_buy_with_symbol_path(@selected_symbol), alert: "Insufficient balance to complete the purchase." and return
    end

    portfolio.update!(balance: portfolio.balance - total_cost)

    holding = portfolio.holdings.find_or_initialize_by(stock_id: stock.id)
    holding.shares ||= 0
    holding.total ||= 0

    holding.update!(
      shares: holding.shares + quantity,
      total: holding.total + total_cost
    )

    Transaction.create!(
      user: @user,
      transaction_type: :buy,
      symbol: @selected_symbol,
      quantity: quantity,
      buy_price: price,
      total_amount: total_cost,
      transaction_date: Date.today
    )

    redirect_to portfolio_path, notice: quantity > 1 ? "Successfully bought #{quantity} shares of #{@selected_symbol}." : "Successfully bought 1 share of #{@selected_symbol}."
  end

  private

  def set_variables
    @selected_symbol = params[:symbol]
  end

  def set_balance
    @balance = @user.portfolio.balance
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

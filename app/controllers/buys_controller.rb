class BuysController < ApplicationController
  def new
    @stocks = Stock.with_price
    @selected_symbol = params[:symbol]
    @selected_price = nil

    if @selected_symbol.present?
      stock = Stock.find_by(symbol: @selected_symbol)

      if stock
        @selected_price = stock.last_price
      else
        flash[:alert] = "Stock not found."
        redirect_to new_buy_path and return
      end
    end

    if @selected_price.to_f.positive? && @balance
      @max_quantity = (@balance / @selected_price).floor
    else
      @max_quantity = nil
    end
  end

  def create
    portfolio = current_user.portfolio
    symbol = params[:symbol]
    price = params[:price].to_f
    quantity = params[:quantity].to_i
    total_cost = price * quantity

    # Validations
    if symbol.blank? || price <= 0 || quantity <= 0
      flash[:alert] = "Invalid purchase request."
      redirect_to new_buy_path and return
    end

    # Find the stock
    stock = Stock.find_by(symbol: symbol)
    unless stock
      flash[:alert] = "Stock not found."
      redirect_to new_buy_path and return
    end

    # Check balance
    if portfolio.balance < total_cost
      flash[:alert] = "Insufficient balance to complete the purchase."
      redirect_to new_with_symbol_buys_path(symbol: symbol) and return
    end

    # Process purchase
    begin
      ActiveRecord::Base.transaction do
        # Deduct balance
        portfolio.update!(balance: portfolio.balance - total_cost)

        # Find or create holding
        holding = portfolio.holdings.find_or_initialize_by(stock_id: stock.id)
        holding.shares ||= 0
        holding.shares += quantity
        holding.buy_price = price
        holding.total = (holding.total || 0) + total_cost
        holding.save!

        # Create transaction record
        Transaction.create!(
          holding_id: holding.id,
          stock_id: stock.id,
          transaction_type: :buy,
          quantity: quantity,
          buy_price: price,
          total_amount: total_cost,
          transaction_date: Date.today
        )
      end

      flash[:notice] = "Successfully bought #{quantity} shares of #{symbol}."
      redirect_to portfolio_path
    rescue => e
      flash[:alert] = "Purchase failed: #{e.message}"
      redirect_to new_buy_with_symbol_buys_path(symbol: symbol)
    end
  end
end

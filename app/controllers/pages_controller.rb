class PagesController < ApplicationController
  before_action :set_balance, only: [ :dashboard, :portfolio, :buy, :sell ]
  before_action :set_user, only: [ :settings, :change_role ]
  before_action :set_holdings, only: [ :portfolio, :sell ]

  def dashboard
    @stocks = Rails.cache.fetch("stocks_data", expires_in: 12.hours) do
      Stock.all.map do |stock|
        response = AvaApi.fetch_records(stock.symbol)

        if response && response["Meta Data"] && response["Time Series (Daily)"]
          price = response["Time Series (Daily)"].values.first["1. open"].to_f

          # Update stock.last_price in database
          stock.update(last_price: price)

          {
            symbol: stock.symbol,
            name: stock.name,
            price: price
          }
        else
          Rails.logger.error("Failed to fetch data for #{stock.symbol}: #{response.inspect}")
          {
            symbol: stock.symbol,
            name: stock.name,
            price: "N/A"
          }
        end
      end
    end
  end


  def portfolio; end

  def deposit_form
    render partial: "deposit_form"
  end

  def process_deposit
    amount = params[:amount].to_f
    # payment_method = params[:payment_method]
    portfolio = current_user.portfolio

    if amount.positive?
      portfolio.balance += amount
      if portfolio.save
        @balance = portfolio.balance

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("balance", partial: "pages/balance", locals: { balance: @balance }),
              turbo_stream.replace("deposit_modal", partial: "pages/empty_frame") # Replace with empty frame
            ]
          end
          format.html { redirect_to pages_portfolio_path }
        end
      else
        flash[:alert] = "Deposit failed. Please try again."
        redirect_to pages_portfolio_path
      end
    else
      flash[:alert] = "Invalid deposit amount."
      redirect_to pages_portfolio_path
    end
  end

  def change_role
    if @user.update(role: params[:user][:role])
      redirect_to root_path, notice: "User role updated successfully."
    else
      redirect_to settings_path, alert: "Failed to update role."
    end
  end

  def transactions; end

  def perform_buy
    portfolio = current_user.portfolio
    symbol = params[:symbol]
    price = params[:price].to_f
    quantity = params[:quantity].to_i
    total_cost = price * quantity

    # validator
    if symbol.blank? || price <= 0 || quantity <= 0
      flash[:alert] = "Invalid purchase request."
      redirect_to buy_stocks_path and return
    end

    # Step 2: Find the stock
    stock = Stock.find_by(symbol: symbol)
    unless stock
      flash[:alert] = "Stock not found."
      redirect_to buy_stocks_path and return
    end

    # Step 3: Ensure user has enough balance
    if portfolio.balance < total_cost
      flash[:alert] = "Insufficient balance to complete the purchase."
      redirect_to buy_stocks_path and return
    end

    # Step 4: Update holdings & balance in a transaction
    ActiveRecord::Base.transaction do
      # Deduct balance
      portfolio.update!(balance: portfolio.balance - total_cost)

      # Find or create holding
      holding = portfolio.holdings.find_or_initialize_by(stock_id: stock.id)
      holding.shares ||= 0
      holding.shares += quantity
      holding.buy_price = price # Update buy price to latest purchase price
      holding.total = (holding.total || 0) + total_cost
      holding.save!

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
    redirect_to pages_portfolio_path
  rescue => e
    flash[:alert] = "Purchase failed: #{e.message}"
    redirect_to buy_stocks_path
  end


  def buy
    @stocks = Stock.all
    @selected_symbol = params[:symbol]
    @selected_price = nil

    if @selected_symbol.present?
      stock = Stock.find_by(symbol: @selected_symbol)

      if stock
        @selected_price = stock.last_price
      else
        flash[:alert] = "Stock not found."
        redirect_to buy_stocks_path and return
      end
    end

    if @selected_price.to_f.positive? && @balance
      @max_quantity = (@balance / @selected_price).floor
    else
      @max_quantity = nil
    end
  end

  def sell
    @stocks = Stock.all
    @selected_symbol = params[:symbol]
    @selected_price = nil
    @max_quantity = nil  # Initialize max_quantity

    if @selected_symbol.present?
      holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }

      if holding
        @max_quantity = holding.shares  # Set the maximum quantity that can be sold

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
        redirect_to pages_portfolio_path, alert: "Stock not found in your portfolio"
      end
    end
  end

  def perform_sell
    # Get parameters
    symbol = params[:symbol]
    quantity = params[:quantity].to_i
    sell_price = params[:price].to_f
    total_amount = sell_price * quantity
    portfolio = current_user.portfolio

    # Validations
    if symbol.blank? || quantity <= 0 || sell_price <= 0
      flash[:alert] = "Invalid sell request."
      redirect_to sell_stocks_path and return
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

    stock = holding.stock

    begin
      # Process the sale
      ActiveRecord::Base.transaction do
        # Update portfolio balance
        portfolio.update!(balance: portfolio.balance + total_amount)

        # Update holdings
        holding.shares -= quantity

        # IMPORTANT: Don't delete the holding record even if shares become zero
        # Just update the shares value to zero
        holding.save!

        # Record the transaction
        transaction = Transaction.new(
          holding_id: holding.id,
          stock_id: stock.id,
          transaction_type: :sell,
          quantity: quantity,
          buy_price: sell_price,
          total_amount: total_amount,
          transaction_date: Date.today
        )

        unless transaction.save
          Rails.logger.error("Transaction save failed: #{transaction.errors.full_messages.join(', ')}")
          raise ActiveRecord::Rollback, "Failed to save transaction: #{transaction.errors.full_messages.join(', ')}"
        end
      end

      flash[:notice] = "Successfully sold #{quantity} shares for $#{format('%.2f', total_amount)}."
      redirect_to pages_portfolio_path
    rescue => e
      flash[:alert] = "Sale failed: #{e.message}"
      redirect_to sell_stocks_path(symbol: symbol)
    end
  end

  def holdings; end

  def transactions
    # @transactions = Transaction.where(user_id: current_user.id).order(created_at: :desc)
    @transactions = Transaction.joins(holding: :portfolio)
                            .where(holdings: { portfolio_id: current_user.portfolio.id })
                            .order(transaction_date: :desc)
  end

  private

  def set_balance
    @portfolio = Portfolio.find_by(user_id: current_user.id)
    @balance = @portfolio&.balance
  end

  def set_user
    @user = current_user
  end

  def set_holdings
    @holdings = current_user.portfolio.holdings.includes(:stock)
    @total_holdings = @holdings.sum { |holding| holding.total }
  end
end

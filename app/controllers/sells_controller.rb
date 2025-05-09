class SellsController < TradersController
  include ActionView::Helpers::NumberHelper
  before_action :set_variables
  before_action :set_holdings, only: %i[new create]

  def new
    @max_quantity = @holding&.shares
  end

  def create
    quantity = params[:quantity].to_i

    total_amount = @selected_price * quantity

    @user.portfolio.update!(balance: @user.portfolio.balance + total_amount)

    new_shares = @holding.shares - quantity
    # new_total = [ @holding.total - total_amount, 0 ].max 
    new_total = new_shares.positive? ? (@holding.total * new_shares / @holding.shares) : 0

    if new_shares.positive?
      @holding.update!(shares: new_shares, total: new_total)
    else
      @holding.destroy
    end

    Transaction.create!(
      user: @user,
      transaction_type: :sell,
      symbol: @selected_symbol,
      quantity: quantity,
      buy_price: @selected_price,
      total_amount: total_amount,
      transaction_date: Date.today
    )

    notice_message = "Successfully sold #{quantity} #{'share'.pluralize(quantity)} of #{@selected_symbol} for #{number_to_currency(total_amount)}."
    redirect_to portfolios_path, notice: notice_message
  end

  private

  def set_variables
    @selected_symbol = params[:symbol]
    @selected_price = fetch_cached_price(@selected_symbol, "4. close")
  end

  def set_holdings
    @holdings = @user.portfolio.holdings.includes(:stock)
    @total_holdings = @holdings.sum(&:value)
    @holding = @holdings.find { |h| h.stock.symbol == @selected_symbol }
  end

  def fetch_cached_price(symbol, price_key)
    response = fetch_api_response(symbol)

    if response&.dig("Time Series (Daily)")
      response["Time Series (Daily)"].values.first[price_key].to_f
    else
      Rails.logger.error("Failed to fetch #{price_key} for #{symbol}: #{response.inspect}")
      Stock.find_by(symbol: symbol)&.last_price || 0
    end
  end
end

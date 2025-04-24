class PagesController < ApplicationController
  def home
    if user_signed_in?
      redirect_to pages_dashboard_path
    end
  end

  def dashboard
    @stocks = Stock.all.map do |stock|
      response = AvaApi.fetch_records(stock.symbol)

      if response && response["Meta Data"] && response["Time Series (Daily)"]
        {
          symbol: stock.symbol,
          name: stock.name,
          price: response["Time Series (Daily)"].values.first["1. open"]
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
  def portfolio
    @portfolio = Portfolio.find_by(user_id: current_user.id)
    @balance = @portfolio&.balance
  end

  def deposit_form
    # This action just renders the deposit form partial
    render partial: "deposit_form"
  end
  
  def process_deposit
    amount = params[:amount].to_f
    payment_method = params[:payment_method]
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
end

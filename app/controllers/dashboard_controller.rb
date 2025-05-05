class DashboardController < ApplicationController
  def index
    @stocks = Stock.all.map do |stock|
      response = fetch_api_response(stock.symbol)

      if response && response["Meta Data"] && response["Time Series (Daily)"]
        price = response["Time Series (Daily)"].values.first["1. open"].to_f
        stock.update(last_price: price)

        {
          symbol: stock.symbol,
          name: stock.name,
          price: price
        }
      else
        Rails.logger.error("Failed to parse data for #{stock.symbol}: #{response.inspect}")
        {
          symbol: stock.symbol,
          name: stock.name,
          price: "N/A"
        }
      end
    end

    if current_user.admin?
      redirect_to home_path
      return
    end

     @total_holdings_value = @portfolio.present? ? @portfolio.total_value : 0
  end
end

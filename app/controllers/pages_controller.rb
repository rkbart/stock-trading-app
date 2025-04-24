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
  end
end

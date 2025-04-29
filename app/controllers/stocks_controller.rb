class StocksController < ApplicationController
  def index
    @stocks = Rails.cache.fetch("stocks_data", expires_in: 12.hours) do
      Stock.all.map do |stock|
        response = AvaApi.fetch_records(stock.symbol)

        if response && response["Meta Data"] && response["Time Series (Daily)"]
          price = response["Time Series (Daily)"].values.first["1. open"].to_f
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

  def show
    @stock = Stock.find_by(symbol: params[:id])
    unless @stock
      redirect_to stocks_path, alert: "Stock not found."
    end
  end
end

class DashboardController < ApplicationController
  def index
    @stocks = Stock.all.map do |stock|
      response = fetch_api_response(stock.symbol)

      price = begin
        response.dig("Time Series (Daily)")&.values&.first&.fetch("1. open")&.to_f
      rescue StandardError => e
        Rails.logger.error("Failed to fetch price for #{stock.symbol}: #{e.message}")
        nil
      end

      stock.update(last_price: price) if price

      {
        symbol: stock.symbol,
        name: stock.name,
        price: price || "N/A"
      }
    end

    if @user.admin?
      redirect_to home_path
      return
    end

     @total_holdings_value = @portfolio.present? ? @portfolio.total_value : 0 #  0 or portfolio.total_value
  end
end

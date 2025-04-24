# lib/tasks/update_stock_prices.rake
namespace :stocks do
  desc "Update last_price of stocks from API"
  task update_prices: :environment do
    Stock.all.each do |stock|
      response = AvaApi.fetch_stock_data(stock.symbol)

      if response && response["Time Series (Daily)"]
        latest_data = response["Time Series (Daily)"].values.first
        open_price = latest_data["1. open"].to_f
        stock.update!(last_price: open_price)
        puts "Updated #{stock.symbol}: $#{open_price}"
      else
        puts "Failed to fetch data for #{stock.symbol}"
      end
    end
  end
end

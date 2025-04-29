module StocksHelper
  def format_price(price)
    price.is_a?(Numeric) ? number_to_currency(price) : price
  end
end

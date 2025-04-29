module PortfolioHelper
  def portfolio_value(holdings)
    holdings.sum { |holding| holding.shares * holding.stock.last_price }
  end

  def profit_loss_class(value)
    value.positive? ? "text-green-500" : value.negative? ? "text-red-500" : "text-gray-500"
  end
end

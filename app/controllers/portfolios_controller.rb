class PortfoliosController < ApplicationController
  def show
    @total_holdings_value = @portfolio.total_value # portfolio model
    @holdings = @portfolio.holdings.includes(:stock)
  end
end

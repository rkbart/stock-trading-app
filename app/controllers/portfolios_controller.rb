class PortfoliosController < ApplicationController
  def show; end

  def holdings
    @holdings = @portfolio.holdings.includes(:stock).with_shares.by_symbol
  end
end

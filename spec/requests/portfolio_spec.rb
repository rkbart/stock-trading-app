# spec/requests/portfolios_spec.rb
require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  let(:trader) { create(:user, :trader) }
  let(:portfolio) { create(:portfolio, user: trader) }
  let(:stock) { create(:stock, symbol: "AAPL", name: "Apple Inc.", last_price: 150.0) }
  let!(:holding) { create(:holding, portfolio: portfolio, stock: stock, shares: 20) }

  before do
    sign_in trader, scope: :user
  end

  describe "GET /portfolios/:id" do
    it "returns a successful response" do
      get portfolio_path(portfolio)
      expect(response).to be_successful
    end

    it "displays the correct total holdings value" do
      get portfolio_path(portfolio)
      expect(response.body).to include("$3,000.00")
    end

    it "displays the portfolio holdings" do
      get portfolio_path(portfolio)
      expect(response.body).to include(stock.symbol)
      expect(response.body).to include(stock.name)
      expect(response.body).to include(holding.average_price.to_s)
      expect(response.body).to include(holding.shares.to_s)
    end
  end
end
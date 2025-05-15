# spec/requests/sells_controller_spec.rb
require 'rails_helper'

RSpec.describe "SellsController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved, :with_portfolio) }
  let(:stock) { create(:stock, symbol: "AAPL") }
  let!(:holding) { create(:holding, portfolio: user.portfolio, stock: stock, shares: 10, total: 1000.0) }

  before do
    sign_in user, scope: :user
    allow_any_instance_of(SellsController).to receive(:fetch_api_response).and_return(
      {
        "Time Series (Daily)" => {
          Date.today.to_s => { "4. close" => "150.00" }
        }
      }
    )
    user.portfolio.update!(balance: 500.00)
  end

  describe "GET #new" do
    it "sets max quantity from holdings" do
      holding # create the holding
      get new_sell_path, params: { symbol: stock.symbol }
      expect(response).to be_successful
      expect(assigns(:max_quantity)).to eq(10)
    end
  end

  describe "POST #create" do # User Story 8, sell stock
    context "with partial sale" do
      it "updates holdings and creates transaction" do
        expect {
          post sells_path, params: { symbol: stock.symbol, quantity: 5 }
        }.to change(Transaction, :count).by(1)

        expect(user.portfolio.reload.balance).to eq(1250.00) # 500 + (5*150)
        expect(holding.reload.shares).to eq(5)
        expect(response).to redirect_to(portfolios_path)
      end
    end

    context "with full sale" do
      it "destroys holding" do
        post sells_path, params: { symbol: stock.symbol, quantity: 10 }
        expect { holding.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

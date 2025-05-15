# spec/requests/buys_spec.rb
require 'rails_helper'

RSpec.describe "BuysController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved, :with_portfolio) }
  let(:stock) { create(:stock, symbol: "AAPL", last_price: 150.00) }
  let(:portfolio) { user.portfolio }

  before do
    sign_in user, scope: :user
    allow_any_instance_of(BuysController).to receive(:fetch_api_response).and_return(
      {
        "Time Series (Daily)" => {
          Date.today.to_s => { "1. open" => "150.00" }
        }
      }
    )
    portfolio.update!(balance: 1000.00)
  end

  describe "GET #new" do
    context "with valid symbol" do
      it "sets purchase variables" do
        get new_buy_path, params: { symbol: stock.symbol }
        expect(response).to be_successful
        expect(assigns(:selected_price)).to eq(150.00)
        expect(assigns(:max_quantity)).to eq(6) # 1000 / 150 = 6.66 -> floor to 6
      end
    end

    context "with invalid symbol" do
      it "redirects with alert" do
        get new_buy_path, params: { symbol: "INVALID" }
        expect(response).to redirect_to(new_buy_path)
        expect(flash[:alert]).to include("Stock not found")
      end
    end
  end

  describe "POST #create" do
    context "with balance" do # User Story 5, buy stock by approved trader
      it "creates transaction and updates holdings" do
        expect {
          post buys_path, params: { symbol: stock.symbol, quantity: 5 }
        }.to change(Transaction, :count).by(1)

        expect(portfolio.reload.balance).to eq(250.00) # 1000 - (5*150)
        expect(portfolio.holdings.first.shares).to eq(5)
        expect(response).to redirect_to(portfolio_path)
      end
    end

    context "with insufficient balance" do
      it "redirects with alert" do
        post buys_path, params: { symbol: stock.symbol, quantity: 10 }
        expect(response).to redirect_to(new_buy_with_symbol_path(stock.symbol))
        expect(flash[:alert]).to include("Insufficient balance")
      end
    end
  end
end

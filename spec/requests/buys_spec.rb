require 'rails_helper'

RSpec.describe BuysController, type: :request do
  let(:user) { create(:user, :trader) }
  let(:portfolio) { create(:portfolio, user: user, balance: 10_000) }
  let(:stock) { create(:stock, symbol: "AAPL", last_price: 150) }

  before do
    sign_in user, scope: :user
    portfolio # ensure portfolio is created
  end

  describe "GET #new" do
    context "without symbol" do
      it "returns success" do
        get new_buy_path
        expect(response).to have_http_status(:success)
      end
    end

    context "with valid stock symbol" do
      before do
        allow_any_instance_of(BuysController).to receive(:fetch_cached_price).and_return(150)
      end

      it "assigns selected_price and max_quantity" do
        get new_buy_with_symbol_path(symbol: stock.symbol)
        expect(response).to have_http_status(:success)
        expect(assigns(:selected_price)).to eq(150)
        expect(assigns(:max_quantity)).to eq(66) # 10000 / 150
      end
    end

    context "with invalid stock symbol" do
      it "redirects with alert" do
        get new_buy_with_symbol_path(symbol: "INVALID")
        expect(response).to redirect_to(new_buy_path)
        follow_redirect!
        expect(response.body).to include("Stock not found")
      end
    end
  end

  describe "POST #create" do
    before do
      allow_any_instance_of(BuysController).to receive(:fetch_cached_price).and_return(100)
    end

    context "with sufficient balance" do
      it "creates a transaction and updates portfolio and holdings" do
        post buys_path, params: {
          symbol: stock.symbol,
          quantity: 10
        }

        expect(response).to redirect_to(portfolio_path)
        follow_redirect!
        expect(response.body).to include("Successfully bought 10 shares")
        expect(user.portfolio.reload.balance).to eq(9_000)
      end
    end

    context "with insufficient balance" do
      it "redirects with alert" do
        post buys_path, params: {
          symbol: stock.symbol,
          quantity: 200 # 20000 > 10000 balance
        }

        expect(response).to redirect_to(new_buy_with_symbol_path(stock.symbol))
        follow_redirect!
        expect(response.body).to include("Insufficient balance")
      end
    end
  end
end
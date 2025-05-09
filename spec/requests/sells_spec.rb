require 'rails_helper'

RSpec.describe "Sells", type: :request do
  let(:user) { create(:user, :trader) }
  let(:portfolio) { create(:portfolio, user: user, balance: 1000) }
  let(:stock) { create(:stock, symbol: 'AAPL', name: 'Apple Inc.', last_price: 150.0) }
  let!(:holding) { create(:holding, portfolio: portfolio, stock: stock, shares: 10, total: 1000) }

  before do
    sign_in user, scope: :user
    portfolio
    allow_any_instance_of(SellsController).to receive(:fetch_cached_price).and_return(150.0)
  end

  describe "GET #new" do
    context "with valid stock symbol" do
      it "assigns the correct maximum quantity for the stock" do
        get new_sell_with_symbol_path(symbol: stock.symbol)
        expect(response).to have_http_status(:success)
        expect(assigns(:max_quantity)).to eq(10)
      end
    end
  end
end

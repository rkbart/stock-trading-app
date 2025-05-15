# spec/requests/stocks_controller_spec.rb
require 'rails_helper'

RSpec.describe "StocksController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :approved) } # Assuming you need approved user
  let!(:stock) { create(:stock, symbol: "AAPL", name: "Apple Inc.") }

  before do
    sign_in user, scope: :user
    allow(AvaApi).to receive(:fetch_records).and_return(
      {
        "Meta Data" => {},
        "Time Series (Daily)" => {
          Date.today.to_s => { "1. open" => "150.00" }
        }
      }
    )
  end

  describe "GET #index" do
    it "returns stocks with prices" do
      get stocks_path

      expect(response).to be_successful
      expect(assigns(:stocks).first[:symbol]).to eq("AAPL")
      expect(assigns(:stocks).first[:price]).to eq(150.00)
    end

    it "updates stock price" do
      get stocks_path
      expect(stock.reload.last_price).to eq(150.00)
    end
  end

  describe "GET #show" do
    context "when stock exists" do
      it "shows the stock" do
        get stock_path(stock.symbol)
        expect(response).to be_successful
        expect(assigns(:stock)).to eq(stock)
      end
    end

    context "when stock doesn't exist" do
      it "redirects with alert" do
        get stock_path("INVALID")
        expect(response).to redirect_to(stocks_path)
        expect(flash[:alert]).to include("Stock not found")
      end
    end
  end
end

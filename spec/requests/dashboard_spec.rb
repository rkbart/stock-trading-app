require 'rails_helper'

RSpec.describe DashboardController, type: :request do
  let(:trader) { create(:user, role: :trader, status: "approved") }
  let(:admin)  { create(:user, role: :admin, status: "approved") }
  let!(:stock) { create(:stock, symbol: "AAPL", name: "Apple Inc.") }

  describe "GET #index as trader" do
    before do
      sign_in trader, scope: :user

      allow_any_instance_of(DashboardController).to receive(:fetch_api_response).and_return(
        {
          "Meta Data" => {},
          "Time Series (Daily)" => {
            "2024-01-01" => {
              "1. open" => "100.0"
            }
          }
        }
      )
    end

    it "returns a successful response" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "assigns @stocks with updated prices" do
      get dashboard_path
      expect(assigns(:stocks).first[:price]).to eq(100.0)
    end

    it "assigns @total_holdings_value" do
      get dashboard_path
      expect(assigns(:total_holdings_value)).to eq(trader.portfolio.total_value)
    end
  end
end

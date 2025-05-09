# spec/requests/dashboard_spec.rb
require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  let(:trader) { create(:user, :trader) }
  let!(:aapl_stock) { create(:stock, symbol: 'AAPL', name: 'Apple Inc.') }
  let!(:portfolio) { create(:portfolio, user: trader) }

  describe "GET / (dashboard)" do
    context "when authenticated as trader" do
      before { sign_in trader, scope: :user }

      context "when API response is successful" do
        before do
          # Exact stub matching the real API request
          stub_request(:get, "https://alpha-vantage.p.rapidapi.com/query")
            .with(
              query: {
                'function' => 'TIME_SERIES_DAILY',
                'symbol' => 'AAPL',
                'outputsize' => 'compact',
                'datatype' => 'json'
              },
              headers: {
                'X-Rapidapi-Host' => 'alpha-vantage.p.rapidapi.com',
                'X-Rapidapi-Key' => '2892a51f21mshd2e6029fa6ed0a2p1d83bajsnfe552f480759'
              }
            )
            .to_return(
              status: 200,
              body: {
                "Time Series (Daily)" => { "2025-05-06" => { "1. open" => "150.0" } }
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it "displays AAPL stock information" do
          get root_path
          
          expect(response).to be_successful
          expect(response.body).to include('AAPL')
          expect(response.body).to include('Apple Inc.')
          expect(response.body).to include('$150.0')
        end

        it "updates AAPL price in database" do
          aapl_stock.update!(last_price: nil)
          expect {
            get root_path
            aapl_stock.reload
          }.to change(aapl_stock, :last_price).from(nil).to(150.0)
        end
      end

      context "when API response fails" do
        before do
          stub_request(:get, "https://alpha-vantage.p.rapidapi.com/query")
            .with(
              query: {
                'function' => 'TIME_SERIES_DAILY',
                'symbol' => 'AAPL',
                'outputsize' => 'compact',
                'datatype' => 'json'
              },
              headers: {
                'X-Rapidapi-Host' => 'alpha-vantage.p.rapidapi.com',
                'X-Rapidapi-Key' => '2892a51f21mshd2e6029fa6ed0a2p1d83bajsnfe552f480759'
              }
            )
            .to_return(status: 500)
        end

        it "displays N/A for AAPL price" do
          get root_path
          expect(response.body).to include('AAPL')
          expect(response.body).to include('N/A')
        end
      end
    end
  end
end
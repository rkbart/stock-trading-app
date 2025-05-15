# spec/requests/portfolios_controller_spec.rb
require 'rails_helper'

RSpec.describe "PortfoliosController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved, :with_portfolio) }
  let(:portfolio) { user.portfolio }
  let!(:holding) { create(:holding, portfolio: portfolio) }

  before { sign_in user, scope: :user }

  describe "GET #show" do # User Story 6, show portfolio
    it "shows portfolio with holdings" do
      get portfolio_path(portfolio)

      expect(response).to be_successful
      expect(assigns(:total_holdings_value)).to eq(portfolio.total_value)
      expect(assigns(:holdings)).to include(holding)
    end
  end
end

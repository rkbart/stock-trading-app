# spec/requests/deposits_spec.rb
require 'rails_helper'

RSpec.describe "DepositsController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved, :with_portfolio) }
  let(:portfolio) { user.portfolio }

  before { sign_in user, scope: :user }

  describe "POST #create" do
    context "with valid deposit" do
      it "updates balance and creates transaction" do
        post deposits_path, params: { amount: 500.0, payment_method: "Credit Card" }, as: :turbo_stream

        expect(portfolio.reload.balance).to eq(500.0)
        expect(Transaction.last.attributes).to include(
          "transaction_type" => "deposit",
          "total_amount" => 500.0,
          "symbol" => "Credit Card"
        )
        expect(response.body).to include("turbo-stream action=\"replace\" target=\"balance\"")
      end
    end

    context "with invalid amount" do
      it "renders new" do
        post deposits_path, params: { amount: 0 }
        expect(response).to render_template(:new)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(Portfolio).to receive(:save).and_return(false)
      end

      it "shows alert and redirects" do
        post deposits_path, params: { amount: 500.0 }
        expect(flash[:alert]).to eq("Deposit failed. Please try again.")
        expect(response).to redirect_to(portfolios_path)
      end
    end
  end
end

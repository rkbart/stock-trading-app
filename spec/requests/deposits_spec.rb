require 'rails_helper'

RSpec.describe DepositsController, type: :request do
  let(:user) { create(:user, :trader) }
  let!(:portfolio) { create(:portfolio, user: user, balance: 1000.0) }

  before do
    sign_in user, scope: :user
  end

  describe "POST /deposits" do
    context "with valid deposit amount" do
      it "updates the user's portfolio balance and creates a transaction" do
        expect {
          post deposits_path, params: { amount: 500, payment_method: "Bank Transfer" }
        }.to change { user.portfolio.reload.balance }.from(1000.0).to(1500.0)
         .and change(Transaction, :count).by(1)

        expect(response).to redirect_to(portfolios_path)
      end
    end

    context "with invalid deposit amount (<= 0)" do
      it "does not update the balance or create a transaction" do
        expect {
          post deposits_path, params: { amount: 0, payment_method: "Bank Transfer" }
        }.to_not change(Transaction, :count)
      end
    end

    context "when saving portfolio fails" do
      before do
        allow_any_instance_of(Portfolio).to receive(:save).and_return(false)
      end

      it "redirects with an error message" do
        post deposits_path, params: { amount: 500, payment_method: "Bank Transfer" }

        expect(response).to redirect_to(portfolios_path)
        follow_redirect!
        expect(response.body).to include("Deposit failed. Please try again.")
      end
    end
  end
end

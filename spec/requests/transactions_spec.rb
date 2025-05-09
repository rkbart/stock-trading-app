# spec/requests/transactions_spec.rb
require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  let(:user) { create(:user) }
  let!(:transaction_1) { create(:transaction, 
                               user: user, 
                               transaction_date: 2.days.ago,
                               total_amount: 100.00,
                               transaction_type: :buy) }
  let!(:transaction_2) { create(:transaction, 
                               user: user, 
                               transaction_date: 1.day.ago,
                               total_amount: 150.00,
                               transaction_type: :sell) }

  before { sign_in user, scope: :user }

  describe "GET /transactions" do
    it "returns transactions ordered by most recent first" do
      get transactions_path
      expect(response).to be_successful
      expect(assigns(:transactions)).to eq([transaction_2, transaction_1])
    end

    it "renders the index template" do
      get transactions_path
      expect(response).to render_template(:index)
    end
  end
end
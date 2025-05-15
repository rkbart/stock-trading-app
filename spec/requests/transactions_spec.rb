# spec/requests/transactions_controller_spec.rb
require 'rails_helper'

RSpec.describe "TransactionsController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved) }
  let!(:transaction1) { create(:transaction, user: user, transaction_date: 1.day.ago) }
  let!(:transaction2) { create(:transaction, user: user, transaction_date: Time.current) }

  before { sign_in user, scope: :user }

  describe "GET #index" do # User Story 7, show trader transactions
    it "lists transactions in recent order" do
      get transactions_path

      expect(response).to be_successful
      expect(assigns(:transactions)).to eq([ transaction2, transaction1 ])
    end
  end
end

# spec/requests/admin/users_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:pending_trader) { create(:user, role: :trader, status: "pending") }
  let!(:approved_trader) { create(:user, :approved) }
  let!(:complete_trader) { create(:user, :approved, :with_portfolio) }

  before do
    ActionMailer::Base.deliveries.clear
    sign_in admin, scope: :user
  end

  describe "GET /admin/users" do # User Story 5, show pending traders
    it "displays pending traders" do
      get admin_users_path
      expect(response).to be_successful
      expect(response.body).to include(pending_trader.email)
    end
  end

  describe "POST /admin/users/:id/approve" do # User Story 6, approve trader
    it "approves a trader" do # User Story 4, trader approval email
      ActionMailer::Base.deliveries.clear

      expect {
        patch approve_admin_user_path(pending_trader)
        }.to change(ActionMailer::Base.deliveries, :count).by(1)

      pending_trader.reload

      expect(pending_trader.status).to eq("approved")
      expect(pending_trader.confirmed_at).not_to be_nil
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "GET /admin/users/show_all_traders" do # User Story 4, show all traders
    it "lists all traders" do
      get show_all_traders_admin_users_path
      expect(response).to be_successful
      expect(assigns(:list_of_traders)).to include(approved_trader)
    end
  end

  describe "GET /admin/users/:id" do
    context "with complete profile" do # User Story 3, show trader
      it "shows trader details" do
        get admin_user_path(complete_trader)
        expect(response).to be_successful
        expect(assigns(:user_transactions)).to be_empty
      end
    end

    context "with incomplete profile" do
      let(:incomplete_trader) { create(:user, :approved, :with_incomplete_profile) }

      it "redirects with alert" do
        get admin_user_path(incomplete_trader)
        expect(response).to redirect_to(show_all_traders_admin_users_path)
        expect(flash[:alert]).to include("hasn't completed their profile")
      end
    end
  end

  describe "PATCH /admin/users/:id" do # User Story 2, edit trader
    let(:update_params) do
      {
        user: {
          first_name: "Updated",
          last_name: "Trader",
          birthday: "1990-01-01",
          gender: "Male",
          address: "123 Updated St",
          role: "trader"
        }
      }
    end

    context "with valid params" do
      it "updates the trader profile" do
        patch admin_user_path(complete_trader), params: update_params
        expect(response).to redirect_to(admin_user_path(complete_trader))
        expect(flash[:notice]).to eq("Trader profile updated successfully.")
      end
    end

    context "with invalid params" do
      it "fails to update and renders edit" do
        patch admin_user_path(complete_trader), params: { user: { first_name: "" } }
        expect(response).to redirect_to(admin_user_path(complete_trader))
      end
    end
  end

  describe "GET /admin/users/invite_trader" do
    it "renders invite form" do
      get invite_trader_admin_users_path
      expect(response).to be_successful
    end
  end

  describe "POST /admin/users/send_invite" do # User Story 1, create trader
    context "with valid new email" do
      it "creates and invites new trader" do
        expect {
          post send_invite_admin_users_path, params: { email: 'brand-new@trader.com' }
        }.to change(User, :count).by(1)

        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(response).to redirect_to(admin_user_path(User.last))
      end
    end
  end

  describe "GET /admin/users/all_transactions" do # User Story 7, show all transactions
    let!(:transaction1) { create(:transaction, user: approved_trader) }
    let!(:transaction2) { create(:transaction, user: complete_trader) }

    it "lists all transactions in recent first order" do
      get all_transactions_admin_users_path

      expect(response).to be_successful
      expect(assigns(:all_transactions)).to eq([ transaction2, transaction1 ])
      expect(response.body).to include(transaction1.total_amount.to_s)
      expect(response.body).to include(transaction2.total_amount.to_s)
    end
  end
end

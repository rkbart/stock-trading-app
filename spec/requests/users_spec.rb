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

  describe "GET /admin/users" do
    it "displays pending traders" do
      get admin_users_path
      expect(response).to be_successful
      expect(response.body).to include(pending_trader.email)
    end
  end

  describe "POST /admin/users/:id/approve" do
    it "approves a trader" do
      post approve_admin_user_path(pending_trader)

      expect(response).to redirect_to(home_path)
      # expect(flash[:notice]).to include("has been approved")
      # expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  describe "GET /admin/users/show_all_traders" do
    it "lists all traders" do
      get show_all_traders_admin_users_path
      expect(response).to be_successful
      expect(assigns(:list_of_traders)).to include(approved_trader)
    end
  end

  describe "GET /admin/users/:id" do
    context "with complete profile" do
      it "shows trader details" do
        get admin_user_path(complete_trader)
        expect(response).to be_successful
        expect(assigns(:user_transactions)).to be_empty # No transactions created
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

  describe "GET /admin/users/invite_trader" do
    it "renders invite form" do
      get invite_trader_admin_users_path
      expect(response).to be_successful
    end
  end

  describe "POST /admin/users/send_invite" do
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

  describe "authorization" do
    it "denies non-admin access" do
      sign_in approved_trader, scope: :user
      get admin_users_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("Access denied")
    end
  end
end
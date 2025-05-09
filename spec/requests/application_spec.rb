# spec/requests/application_controller_spec.rb
require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:admin) { create(:user, email: "admin@example.com", role: :admin, password: "password123", password_confirmation: "password123", status: "approved", first_name: "Admin", last_name: "User", slug: "admin-user") }
  let(:trader) { create(:user, email: "trader@example.com", role: :trader, status: "approved", slug: "trader-user") }
  let(:user_with_blank_names) { create(:user, email: "blank@example.com", role: :trader, first_name: "", last_name: "", status: "approved", slug: "blank") }
  let!(:portfolio) { create(:portfolio, user: trader) }

  describe "before actions" do
    context "when the user is not signed in" do
      it "redirects to the login page" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is signed in" do
      before { sign_in trader }

      it "sets @user to the current user" do
        get dashboard_path
        expect(assigns(:user)).to eq(trader)
      end

      it "sets @portfolio if the user is a trader" do
        get dashboard_path
        expect(assigns(:portfolio)).to eq(trader.portfolio)
      end

      it "does not set @portfolio if the user is not a trader" do
        sign_in admin
        get home_path
        expect(assigns(:portfolio)).to be_nil
      end
    end
  end

  describe "after_sign_in_path_for behavior" do
    it "redirects to the home path for admin" do
      sign_in admin, scope: :user
      get root_path
      expect(response).to redirect_to(home_path)
    end

    it "redirects to edit profile path if name is missing" do
      post user_session_path, params: {
        user: { email: user_with_blank_names.email, password: user_with_blank_names.password }
      }
      expect(response).to redirect_to(edit_profile_path)
    end
  end

  describe "require_trader!" do
    context "when a trader accesses a trader-only page" do
      it "allows access" do
        sign_in trader
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

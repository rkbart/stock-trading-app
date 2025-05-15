# spec/requests/application_controller_spec.rb
require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let(:trader) { create(:user, :approved, :with_portfolio) }

  describe "authentication #before_action" do
    context "when not signed in" do
      it "redirects to login" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in trader }

      it "sets @user and @portfolio" do
        get dashboard_path
        expect(assigns(:user)).to eq(trader)
        expect(assigns(:portfolio)).to eq(trader.portfolio)
      end
    end
  end

  describe "after_sign_in_path_for" do
    it "redirects admin to home_path" do
      sign_in admin
      get root_path
      expect(response).to redirect_to(home_path)
    end

    it "redirects incomplete profile to edit" do
      sign_in trader
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "require_trader!" do
    it "allows trader access" do
      sign_in trader
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "denies admin access" do
      sign_in admin
      get dashboard_path
      expect(response).to redirect_to(home_path)
    end
  end
end
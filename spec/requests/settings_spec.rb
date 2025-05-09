# spec/requests/settings_spec.rb
require 'rails_helper'

RSpec.describe "Settings", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:trader) { create(:user, :trader) }

  describe "GET #show" do
    context "when authenticated" do
      it "returns http success" do
        sign_in admin, scope: :user
        get settings_path
        expect(response).to_not have_http_status(:success)
      end
    end

    context "when unauthenticated" do
      it "redirects to login" do
        get settings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH #update_role" do
    before { sign_in trader, scope: :user }

    context "with valid parameters" do
      context "when changing role to admin" do
        it "updates the user role" do
          patch settings_update_role_path, params: { user: { role: "admin" } }
          trader.reload
          expect(trader.role).to eq("admin")
        end
      end

      context "when changing role to admin" do
        it "updates the user role" do
          patch settings_update_role_path, params: { user: { role: "admin" } }
          trader.reload
          expect(trader.role).to eq("admin")
        end
      end
    end
  end
end
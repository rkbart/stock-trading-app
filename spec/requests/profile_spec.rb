# spec/requests/profiles_controller_spec.rb
require 'rails_helper'

RSpec.describe "ProfilesController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :trader, :approved) }

  before { sign_in user, scope: :user }

  describe "GET #show" do
    context "with complete profile" do
      it "shows the profile" do
        get profile_path
        expect(response).to be_successful
      end
    end

    context "with incomplete profile" do
      let(:user) { create(:user, :trader, :approved, :with_incomplete_profile) }

      it "redirects to edit" do
        get profile_path
        expect(response).to redirect_to(edit_profile_path)
        expect(flash[:alert]).to include("You haven't completed your profile yet")
      end
    end
  end

  describe "GET #edit" do
    it "shows edit form" do
      get edit_profile_path
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates profile" do
        patch profile_path, params: { user: { first_name: "Updated" } }
        expect(user.reload.first_name).to eq("Updated")
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to include("Profile updated successfully")
      end
    end

    context "with invalid params" do
      it "renders edit" do
        patch profile_path, params: { user: { first_name: "" } }
        expect(response).to redirect_to(profile_path)
      end
    end
  end
end

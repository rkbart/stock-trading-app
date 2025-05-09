# spec/requests/profiles_spec.rb
require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  before { sign_in user, scope: :user }

  describe "GET /profile" do
    context "when user has incomplete profile" do
      before do
        user.update(first_name: "", last_name: "", birthday: "", gender: "", address: "")
      end

      it "redirects to edit_profile_path with an alert" do
        get profile_path
        expect(response).to redirect_to(edit_profile_path)
        expect(flash[:alert]).to eq("You haven't completed your profile yet.")
      end
    end

    context "when user has completed profile" do
      before do
        user.update(first_name: "John", last_name: "Doe", birthday: "1990-01-01", gender: "Male", address: "123 Street")
      end

      it "returns a successful response" do
        get profile_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /profile/edit" do
    it "returns a successful response" do
      get edit_profile_path
      expect(response).to be_successful
    end
  end

  describe "PATCH /profile" do
    context "with valid parameters" do
      let(:valid_params) { { user: { first_name: "John", last_name: "Doe", birthday: "1990-01-01", gender: "Male", address: "123 Street" } } }

      it "updates the user profile" do
        patch profile_path, params: valid_params
        user.reload
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
        expect(user.birthday).to eq(Date.new(1990, 1, 1))
        expect(user.gender).to eq("Male")
        expect(user.address).to eq("123 Street")
      end

      it "redirects to the profile path with a notice" do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq("Profile updated successfully.")
      end
    end
  end
end
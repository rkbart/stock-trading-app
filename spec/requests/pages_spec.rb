# spec/requests/pages_controller_spec.rb
require 'rails_helper'

RSpec.describe "PagesController", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET #home" do
    context "when trader" do
      let(:trader) { create(:user, :trader) }

      it "denies access" do
        sign_in trader, scope: :user
        get home_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end

    context "when admin" do
      let(:admin) { create(:user, :admin) }

      it "allows access" do
        sign_in admin, scope: :user
        get home_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET #about" do
    context "when admin" do
      let(:admin) { create(:user, :admin) }

      it "denies access" do
        sign_in admin
        get about_path
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("Access denied")
      end
    end

    context "when trader" do
      let(:trader) { create(:user, :trader) }

      it "allows access" do
        sign_in trader
        get about_path
        expect(response).to be_successful
      end
    end
  end
end

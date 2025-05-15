require 'rails_helper'

RSpec.describe "Devise Registrations", type: :request do
  let(:user_attrs) { attributes_for(:user) }
  let(:existing_user) { create(:user) }

  describe "POST /users, USER SIGN UP" do # User Story 1 & 3, create account and send email
    it "creates a new user" do
      expect {
        post user_registration_path, params: { user: user_attrs }
      }.to change(User, :count).by(1).and change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "redirects after successful registration" do
      post user_registration_path, params: { user: user_attrs }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /users/sign_in, USER LOGIN" do # User Story 2, login
    context "with valid credentials" do
      it "logs in successfully" do
        post user_session_path, params: {
          user: {
            email: existing_user.email,
            password: existing_user.password
          }
        }
        expect(response).to redirect_to(root_path)
        expect(controller.current_user).to eq(existing_user)
      end
    end

    context "with invalid credentials" do
      it "fails to log in" do
        post user_session_path, params: {
          user: {
            email: existing_user.email,
            password: 'wrongpassword'
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Invalid Email or password')
        expect(controller.current_user).to be_nil
      end
    end
  end
end

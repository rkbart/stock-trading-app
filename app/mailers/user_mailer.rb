class UserMailer < ApplicationMailer
  default from: "avionschoolproject@gmail.com"
  before_action :set_url

  def invitation_email
    mail(to: @user.email, subject: "You've been invited to RailsTrade App!")
  end

  def welcome_email
    mail(to: @user.email, subject: "Welcome to RailsTrade App!")
  end

  def rejection_email
    mail(to: @user.email, subject: "Your account has been rejected")
  end

  private

  def set_url
    @user = params[:user]
    @url = "localhost:3000/users/sign_in"
  end
end

class PagesController < ApplicationController
  def home
    if @user.trader?
      redirect_to root_path, alert: "Access denied."
      nil
    end
  end
  def about
    if @user.admin?
      redirect_to home_path, alert: "Access denied."
      nil
    end
  end
end

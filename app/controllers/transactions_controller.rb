class TransactionsController < ApplicationController
  def index
    @transactions = @user.transactions.recent_first
  end
end

class TransactionsController < ApplicationController
  def index
    @transactions = @user.transactions.order(transaction_date: :desc)
  end
end

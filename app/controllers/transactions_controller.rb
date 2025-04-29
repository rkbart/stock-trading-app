class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.for_portfolio(current_user.portfolio.id).recent_first
  end
end

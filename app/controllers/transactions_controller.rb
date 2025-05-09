class TransactionsController < TradersController
  def index
    @transactions = @user.transactions.recent_first
  end
end

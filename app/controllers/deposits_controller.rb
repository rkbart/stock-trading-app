class DepositsController < TradersController
  def create
    amount = params[:amount].to_f
    payment_method = params[:payment_method]
    portfolio = @user.portfolio

    if amount.positive?
      portfolio.balance += amount
      if portfolio.save
        @balance = portfolio.balance

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("balance", partial: "shared/balance", locals: { balance: @balance }),
              turbo_stream.replace("deposit_modal", partial: "shared/empty_frame")
            ]
          end

          Transaction.create!(
            user: @user,
            transaction_type: :deposit,
            quantity: nil,
            buy_price: amount,
            symbol: payment_method,
            total_amount: amount,
            transaction_date: Date.today
          )

          format.html { redirect_to portfolios_path }
        end
      else
        flash[:alert] = "Deposit failed. Please try again."
        redirect_to portfolios_path
      end
    else
      # flash[:alert] = "Invalid deposit amount."
      render :new
    end
  end
end

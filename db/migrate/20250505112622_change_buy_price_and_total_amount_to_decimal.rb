class ChangeBuyPriceAndTotalAmountToDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :transactions, :buy_price, :decimal, precision: 15, scale: 2
    change_column :transactions, :total_amount, :decimal, precision: 15, scale: 2
  end
end

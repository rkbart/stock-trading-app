class RemoveBuyPriceFromHoldings < ActiveRecord::Migration[8.0]
  def change
    remove_column :holdings, :buy_price, :decimal
  end
end

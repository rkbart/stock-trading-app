class RemoveStockAndHoldingFromTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_column :transactions, :stock_id, :integer
    remove_column :transactions, :holding_id, :integer
  end
end

class AddTotalToHoldings < ActiveRecord::Migration[8.0]
  def change
    add_column :holdings, :total, :decimal
  end
end

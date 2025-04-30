class AddSymbolToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :symbol, :string
  end
end

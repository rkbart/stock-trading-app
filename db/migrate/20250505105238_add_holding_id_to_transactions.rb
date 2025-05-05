class AddHoldingIdToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :transactions, :holding, foreign_key: true
  end
end

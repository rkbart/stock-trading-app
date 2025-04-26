class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :stock, null: false, foreign_key: true
      t.references :holding, null: false, foreign_key: true
      t.integer :transaction_type
      t.integer :quantity
      t.integer :buy_price
      t.integer :total_amount
      t.date :transaction_date

      t.timestamps
    end
  end
end

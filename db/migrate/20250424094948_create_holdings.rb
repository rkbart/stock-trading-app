class CreateHoldings < ActiveRecord::Migration[8.0]
  def change
    create_table :holdings do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :shares
      t.decimal :buy_price

      t.timestamps
    end
  end
end

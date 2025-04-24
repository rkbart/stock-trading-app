class AddBalanceToPortfolios < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :balance, :decimal, precision: 15, scale: 2, default: 0.0
  end
end

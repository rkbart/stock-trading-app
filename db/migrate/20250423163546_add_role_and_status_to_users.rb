class AddRoleAndStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer, default: 0  # 0 = trader, 1 = admin
    add_column :users, :status, :string, default: "pending"
  end
end

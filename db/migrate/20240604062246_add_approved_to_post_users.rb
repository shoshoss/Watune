class AddApprovedToPostUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :post_users, :approved, :boolean, default: true, null: false
  end
end

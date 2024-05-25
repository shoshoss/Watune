class AddGuestToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :guest, :boolean, default: false, null: false
  end
end

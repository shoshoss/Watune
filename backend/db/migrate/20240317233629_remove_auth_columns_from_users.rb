class RemoveAuthColumnsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
    remove_column :users, :access_token, :string
    remove_column :users, :refresh_token, :string
  end
end

class RemoveAuthColumnsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :provider, :string, if_exists: true
    remove_column :users, :uid, :string, if_exists: true
    remove_column :users, :access_token, :string, if_exists: true
    remove_column :users, :refresh_token, :string, if_exists: true
  end
end

class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :display_name, limit: 50
      t.string :username_slug, limit: 15
      t.string :self_introduction, limit: 500
      t.string :avatar_url, limit: 255
      t.integer :role, default: 0
    end
    add_index :users, :username_slug, unique: true
  end
end

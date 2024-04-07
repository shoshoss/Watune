class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :display_name
      t.string :username_slug
      t.string :email, null: false
      t.string :password_digest, null: false
      t.text :self_introduction
      t.string :avatar_url
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token

      t.timestamps
      t.index :email, unique: true
    end
  end
end

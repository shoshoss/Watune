class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :username_slug
      t.string :email
      t.string :password_digest
      t.text :self_introduction
      t.string :avatar_url
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token

      t.timestamps
    end
  end
end

class UpdateUsersForDevise < ActiveRecord::Migration[7.1]
  def change
    # password_digestをencrypted_passwordにリネーム
    # rename_columnはchange_tableの外で呼び出す
    rename_column :users, :password_digest, :encrypted_password

    # Deviseに必要な他のカラムを追加
    change_table :users, bulk: true do |t|
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # メール認証やアカウントロック機能を使用する場合
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unlock_token
      t.datetime :locked_at
    end

    # インデックスを追加
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
  end
end

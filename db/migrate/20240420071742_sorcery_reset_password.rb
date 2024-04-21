class SorceryResetPassword < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :reset_password_token, default: nil
      t.datetime :reset_password_token_expires_at, default: nil
      t.datetime :reset_password_email_sent_at, default: nil
      t.integer :access_count_to_reset_password_page, default: 0
    end

    add_index :users, :reset_password_token, unique: true
  end
end

class CreatePostUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :post_users do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false # 'direct_recipient', 'reply_recipient', 'community_recipient'

      t.timestamps
    end
  end
end

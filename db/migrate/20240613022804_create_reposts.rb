class CreateReposts < ActiveRecord::Migration[7.1]
  def change
    create_table :reposts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end

    # リポストは一度しかできないようにユニークインデックスを追加
    add_index :reposts, %i[user_id post_id], unique: true
  end
end

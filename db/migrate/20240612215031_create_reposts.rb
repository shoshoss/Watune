class CreateReposts < ActiveRecord::Migration[7.1]
  def change
    create_table :reposts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :original_post, null: false, foreign_key: { to_table: :posts }
      t.text :body

      t.timestamps
    end
  end
end

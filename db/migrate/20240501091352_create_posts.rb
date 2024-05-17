class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.binary :audio
      t.integer :privacy, default: 0, null: false

      t.timestamps
    end
  end
end

class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content
      t.string :audio_url
      t.integer :privacy

      t.timestamps
    end
  end
end

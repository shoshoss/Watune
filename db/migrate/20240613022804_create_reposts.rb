class CreateReposts < ActiveRecord::Migration[7.1]
  def change
    create_table :reposts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repostable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :reposts, %i[user_id repostable_id repostable_type], unique: true, name: 'index_reposts_on_user_and_repostable'
  end
end

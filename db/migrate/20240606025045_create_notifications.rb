class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :notifiable, polymorphic: true, null: false
      t.boolean :unread, default: true, null: false
      t.string :action, null: false

      t.timestamps
    end

    add_index :notifications, :unread
  end
end

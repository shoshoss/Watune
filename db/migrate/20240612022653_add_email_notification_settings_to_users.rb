class AddEmailNotificationSettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :notification_email
      t.boolean :email_notify_on_reply, default: true, null: false
      t.boolean :email_notify_on_direct_message, default: true, null: false
    end
  end
end

class AddEmailNotificationSettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :notification_email
      t.boolean :notify_on_reply, default: true, null: false
      t.boolean :notify_on_direct_message, default: true, null: false
      t.boolean :notify_on_like, default: true, null: false
      t.boolean :notify_on_follow, default: true, null: false
      t.string :notification_frequency, default: 'real-time'
    end
  end
end

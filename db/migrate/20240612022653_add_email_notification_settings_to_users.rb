class AddEmailNotificationSettingsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :notification_email
      t.boolean :notify_on_reply, default: true, null: false
      t.boolean :notify_on_direct_message, default: true, null: false
      t.boolean :notify_on_like, default: true, null: false
      t.boolean :notify_on_follow, default: true, null: false
      t.boolean :email_notify_on_reply, default: true, null: false
      t.boolean :email_notify_on_direct_message, default: true, null: false
      t.boolean :email_notify_on_like, default: false, null: false
      t.boolean :email_notify_on_follow, default: false, null: false
      t.string :notification_frequency, default: 'real-time', null: false
      t.datetime :notification_time, null: true
      t.integer :notification_weekday, default: 0, null: false  # 日曜日をデフォルトとする
    end
  end
end

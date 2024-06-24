namespace :data_migration do
  desc 'Migrate Reply notifications to Post notifications'
  task migrate_notifications: :environment do
    Notification.where(notifiable_type: 'Reply').find_each do |notification|
      # バリデーションをスキップしてupdate
      notification.update(notifiable_type: 'Post', validate: false)
    end
    puts 'Data migration completed.'
  end
end

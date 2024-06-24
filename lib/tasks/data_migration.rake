# lib/tasks/data_migration.rake
namespace :data_migration do
  desc "Migrate notifications from Reply to Post"
  task migrate_notifications: :environment do
    Notification.where(notifiable_type: 'Reply').find_each do |notification|
      notification.update_columns(notifiable_type: 'Post')
    end
    puts "Notification data migration completed."
  end
end

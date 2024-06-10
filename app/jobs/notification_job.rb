# app/jobs/notification_job.rb
class NotificationJob < ApplicationJob
  queue_as :default

  # 通知タイプと投稿IDを受け取る
  def perform(notification_type, post_id)
    post = Post.find(post_id)
    case notification_type
    when 'reply'
      post.create_notification_reply(post.user)
      UserMailer.reply_notification(post.parent_post.user, post).deliver_later
    when 'direct_post'
      post.create_notification_post(post.user)
      post.post_users.each do |post_user|
        UserMailer.direct_notification(post_user.user, post).deliver_later
      end
    else
      Rails.logger.error "Unknown notification type: #{notification_type}"
    end
  end
end

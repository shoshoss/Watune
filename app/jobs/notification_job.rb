class NotificationJob < ApplicationJob
  queue_as :default # デフォルトのキューにジョブを送る

  def perform(notification_type, post_id)
    post = Post.find(post_id)
    case notification_type
    when 'reply'
      post.create_notification_reply(post.user)
    when 'direct'
      post.create_notification_post(post.user)
    else
      Rails.logger.error "Unknown notification type: #{notification_type}"
    end
  end
end

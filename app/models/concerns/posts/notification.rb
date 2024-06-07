module Posts
  module Notification
    extend ActiveSupport::Concern

    included do
      # いいねの通知を作成するメソッド
      def create_notification_like!(current_user, like)
        return if current_user.id == user_id # 自分の投稿に対するいいねは通知しない

        notification = current_user.sent_notifications.new(
          recipient_id: user_id,
          sender_id: current_user.id,
          notifiable: like,
          action: 'like',
          unread: true
        )
        notification.save if notification.valid?
      end

      # 返信の通知を作成するメソッド
      def create_notification_reply!(current_user, reply)
        notification = current_user.sent_notifications.new(
          recipient_id: user_id,
          sender_id: current_user.id,
          notifiable: reply,
          action: 'reply',
          unread: true
        )
        notification.save if notification.valid?
      end

      # 投稿の通知を作成するメソッド
      def create_notification_for_recipients(current_user)
        recipients = post_users.where(role: 'direct_recipient').pluck(:user_id)
        recipients.each do |recipient_id|
          next if recipient_id == current_user.id # 自分自身への通知は不要

          notification = current_user.sent_notifications.new(
            recipient_id: recipient_id,
            sender_id: current_user.id,
            notifiable: self,
            action: 'post',
            unread: true
          )
          notification.save if notification.valid?
        end
      end
    end
  end
end

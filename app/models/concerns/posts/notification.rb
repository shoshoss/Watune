# app/models/concerns/posts/notification.rb
module Posts
  module Notification
    extend ActiveSupport::Concern

    included do
      # いいねの通知を作成するメソッド
      def create_notification_like!(current_user)
        return if current_user.id == user_id # 自分の投稿に対するいいねは通知しない

        notification = current_user.sent_notifications.new(
          recipient_id: user_id, # 通知の受信者
          sender_id: current_user.id, # 通知の送信者
          notifiable: self, # いいねされた投稿
          action: 'like', # アクションタイプ
          unread: true # 未読状態
        )
        notification.save if notification.valid?
      end

      # 返信の通知を作成するメソッド
      def create_notification_reply!(current_user, reply)
        notification = current_user.sent_notifications.new(
          recipient_id: self.parent_post.user_id, # 返信の親投稿のユーザーIDを通知の受信者とする
          sender_id: current_user.id, # 通知の送信者
          notifiable: reply, # 返信
          action: 'reply', # アクションタイプ
          unread: true # 未読状態
        )
        notification.save if notification.valid?
      end

      # 投稿の通知を作成するメソッド
      def create_notification_for_recipients(current_user)
        recipients = self.post_users.where(role: 'direct_recipient').pluck(:user_id)
        recipients.each do |recipient_id|
          next if recipient_id == current_user.id # 自分自身への通知は不要

          notification = current_user.sent_notifications.new(
            recipient_id: recipient_id, # 通知の受信者
            sender_id: current_user.id, # 通知の送信者
            notifiable: self, # 投稿
            action: 'post', # アクションタイプ
            unread: true # 未読状態
          )
          notification.save if notification.valid?
        end
      end
    end
  end
end

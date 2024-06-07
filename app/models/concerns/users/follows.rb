module Users
  module Follows
    extend ActiveSupport::Concern

    included do
      has_many :active_friendships, class_name: 'Friendship', foreign_key: :follower_id, dependent: :destroy,
                                    inverse_of: :follower
      has_many :passive_friendships, class_name: 'Friendship', foreign_key: :followed_id, dependent: :destroy,
                                     inverse_of: :followed
      has_many :followings, through: :active_friendships, source: :followed
      has_many :followers, through: :passive_friendships, source: :follower

      # フォロー関連のインスタンスメソッド
      def follow(user)
        active_friendships.find_or_create_by!(followed_id: user.id)
        create_notification_follow!(user) # フォロー時に通知を作成
      end

      def unfollow(user)
        friendship = active_friendships.find_by(followed_id: user.id)
        friendship&.destroy!
      end

      def following?(user)
        active_friendships.exists?(followed_id: user.id)
      end

      
      # フォローしているユーザーの投稿回数を取得し、送信回数でソート
      def following_ordered_by_sent_posts
        following_ids = followings.pluck(:id)
        user_post_counts = PostUser.where(user_id: following_ids).group(:user_id).count
        followings_with_counts = followings.map { |user| [user, user_post_counts[user.id] || 0] }
        followings_with_counts.sort_by { |_, count| -count }.map(&:first)
      end

      # フォロー時の通知を作成するメソッド
      def create_notification_follow!(followed_user)
        notification = sent_notifications.new(
          recipient_id: followed_user.id,
          sender_id: id,
          notifiable: followed_user,
          action: 'follow',
          unread: true
        )
        notification.save if notification.valid?
      end
    end
  end
end

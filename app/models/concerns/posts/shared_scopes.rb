module Posts
  module SharedScopes
    extend ActiveSupport::Concern

    included do
      # 共通部分の抽出
      scope :direct_recipient_posts, lambda { |user|
        joins(:post_users).where(
          post_users: { user_id: user, role: 'direct_recipient' }
        )
      }

      # 相互のダイレクトメッセージや複数選択の送受信、返信のやり取りを表示するスコープ
      scope :shared_with_you, lambda { |current_user, profile_user|
        if current_user.nil? || profile_user.nil?
          Post.none
        else
          direct_recipient_posts_to_profile_user = direct_recipient_posts(current_user).where(user_id: profile_user.id)
          direct_recipient_posts_to_current_user = direct_recipient_posts(profile_user).where(user_id: current_user.id)

          reply_from_current_user = where(
            user_id: current_user.id,
            post_reply_id: Post.where(user_id: profile_user.id).select(:id)
          )
          # プロフィールユーザーが返信した投稿を取得
          reply_from_profile_user = where(
            user_id: profile_user.id,
            post_reply_id: Post.where(user_id: current_user.id).select(:id)
          )

          Post.where(id: direct_recipient_posts_to_profile_user.select(:id))
              .or(Post.where(id: direct_recipient_posts_to_current_user.select(:id)))
              .or(Post.where(id: reply_from_current_user.select(:id)))
              .or(Post.where(id: reply_from_profile_user.select(:id)))
              .distinct
        end
      }

      # 仲間からの投稿を取得するスコープ
      scope :posts_to_you, lambda { |user|
        direct_recipient_posts(user)
          .or(where(post_reply_id: Post.where(user_id: user).select(:id)))
          .distinct
      }
    end
  end
end

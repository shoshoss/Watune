module Posts
  module SharedScopes
    extend ActiveSupport::Concern

    included do
      # 自分だけの投稿を取得するスコープ
      scope :only_me, -> { where(privacy: 'only_me').order(created_at: :desc) }

      # 公開設定された自分の投稿を取得するスコープ
      scope :my_posts_open, -> { where(privacy: 'open').order(created_at: :desc) }

      # 仲間への投稿を取得するスコープ
      scope :my_posts_following, lambda { |user|
        direct_posts = joins(:post_users).where(
          # 指定されたユーザーが直接受信者である投稿を取得
          post_users: { user_id: user.id, role: 'direct_recipient' }
        )
        # 指定されたユーザーが返信した投稿を取得
        reply_posts = where(user_id: user.id, post_reply_id: Post.select(:id))

        Post.where(id: direct_posts.select(:id))
            .or(Post.where(id: reply_posts.select(:id)))
            .distinct.order(created_at: :desc)
      }

      # 仲間からの投稿を取得するスコープ
      scope :posts_to_you, lambda { |user|
        # 指定されたユーザーが直接受信者である投稿を取得
        direct_posts = joins(:post_users).where(
          post_users: { user_id: user.id, role: 'direct_recipient' }
        )
        # 指定されたユーザーが返信された投稿を取得
        reply_posts = where(post_reply_id: Post.where(user_id: user.id).select(:id))

        Post.where(id: direct_posts.select(:id))
            .or(Post.where(id: reply_posts.select(:id)))
            .distinct.order(created_at: :desc)
      }

      # 相互のダイレクトメッセージや複数選択の送受信、返信のやり取りを表示するスコープ
      scope :shared_with_you, lambda { |current_user, profile_user|
        # 指定されたユーザーと現在のユーザー間のダイレクトメッセージを取得
        direct_to_profile_user = joins(:post_users).where(
          user_id: current_user.id,
          post_users: { user_id: profile_user.id, role: 'direct_recipient', approved: true }
        )
        direct_to_current_user = joins(:post_users).where(
          user_id: profile_user.id,
          post_users: { user_id: current_user.id, role: 'direct_recipient', approved: true }
        )
        # 現在のユーザーが返信した投稿を取得
        reply_from_current_user = where(
          user_id: current_user.id,
          post_reply_id: Post.where(user_id: profile_user.id).select(:id)
        )
        # プロフィールユーザーが返信した投稿を取得
        reply_from_profile_user = where(
          user_id: profile_user.id,
          post_reply_id: Post.where(user_id: current_user.id).select(:id)
        )

        Post.where(id: direct_to_profile_user.select(:id))
            .or(Post.where(id: direct_to_current_user.select(:id)))
            .or(Post.where(id: reply_from_current_user.select(:id)))
            .or(Post.where(id: reply_from_profile_user.select(:id)))
            .distinct.order(created_at: :desc)
      }
    end
  end
end

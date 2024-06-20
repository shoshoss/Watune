module Posts
  module UserPostScopes
    extend ActiveSupport::Concern

    included do
      # 自分だけの投稿を取得するスコープ
      scope :only_me, -> { where(privacy: 'only_me').order(created_at: :desc) }

      # 公開設定された自分の投稿を取得するスコープ
      scope :my_posts_open, -> { where(privacy: 'open').order(created_at: :desc) }

      # 仲間への投稿を取得するスコープ（自分がselected_usersで投稿したものを取得するスコープ）
      scope :my_posts_following, lambda { |user|
        direct_posts = where(user_id: user.id, privacy: Post.privacies[:selected_users])
        reply_posts = where(user_id: user.id, post_reply_id: Post.select(:id))

        Post.where(id: direct_posts.select(:id))
            .or(Post.where(id: reply_posts.select(:id)))
            .distinct.order(created_at: :desc)
      }

      # 仲間からの投稿を取得するスコープ
      scope :posts_to_you, lambda { |user|
        direct_posts = joins(:post_users).where(
          post_users: { user_id: user, role: 'direct_recipient' }
        )
        reply_posts = where(post_reply_id: Post.where(user_id: user).select(:id))

        Post.where(id: direct_posts.select(:id))
            .or(Post.where(id: reply_posts.select(:id)))
            .distinct.order(created_at: :desc)
      }
    end
  end
end

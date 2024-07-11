module Posts
  module UserPostScopes
    extend ActiveSupport::Concern

    included do
      # 自分だけの投稿を取得するスコープ
      scope :only_me, -> { where(privacy: 'only_me') }

      # 仲間への投稿を取得するスコープ（自分がselected_usersで投稿したものを取得するスコープ）
      scope :my_posts_following, lambda { |user, base_scope = Post.all|
        direct_posts = base_scope.where(user_id: user.id, privacy: Post.privacies[:selected_users])
        reply_posts = base_scope.where(user_id: user.id, post_reply_id: Post.select(:id))

        Post.where(id: direct_posts.select(:id))
            .or(Post.where(id: reply_posts.select(:id)))
            .distinct
      }

      # 公開設定された自分の投稿を取得するスコープ
      scope :my_posts_open, -> { where(privacy: 'open') }
    end
  end
end
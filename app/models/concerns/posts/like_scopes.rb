module Posts
  module LikeScopes
    extend ActiveSupport::Concern

    included do
      # 投稿者本人が自分に「いいね」をしていない投稿を取得するスコープ
      scope :not_liked_by_user, lambda { |user|
        where(user_id: user.id)
          .where.not(id: Like.select(:post_id).where(user_id: user.id))
          .order(created_at: :asc)
      }

      # 自分の投稿で自分がいいねしていないもの、および他のユーザーの公開設定された投稿で、
      # いいねの数が0から9の範囲に収まるものを取得するスコープ
      scope :with_likes_count_all, lambda { |user|
        user_posts = where(user_id: user.id)
                     .left_joins(:likes)
                     .group('posts.id')
                     .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
                     .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
                     .order(created_at: :asc)

        open_posts = where.not(user_id: user.id)
                          .where(privacy: 'open')
                          .left_joins(:likes)
                          .group('posts.id')
                          .having('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) <= 9')
                          .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
                          .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
                          .order(created_at: :asc)

        user_posts.or(open_posts)
      }

      # 自分以外のユーザーの公開設定された投稿を、投稿者本人のいいねを除外していいねの数が0から9のものに限定して取得するスコープ
      scope :public_likes_chance, lambda { |user|
        where.not(user_id: user.id)
             .where(privacy: 'open')
             .left_joins(:likes)
             .group('posts.id')
             .having('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) <= 9')
             .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
             .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
             .order(created_at: :asc)
      }
    end
  end
end

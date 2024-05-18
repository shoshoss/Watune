class Post < ApplicationRecord
  extend ActiveRecordExtended::QueryMethods

  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  # Active Storageを使って添付ファイルを管理する
  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3599 },
                       allow_nil: true

  # 投稿のプライバシーレベル
  enum privacy: { only_me: 0, friends_only: 1, open: 2 }

  # スコープ: 公開設定の投稿を表示
  scope :visible_to, ->(user) { where(privacy: %i[open friends_only]).or(where(user:)) }

  # スコープ: ユーザーがいいねしていない投稿を取得
  scope :not_liked_by_user, ->(user) { where(user_id: user.id).left_joins(:likes).where(likes: { user_id: nil }) }

  # スコープ: 自分の投稿で自分がいいねしていないもの、および他のユーザーの公開設定された投稿で、そのユーザー自身がいいねしていない、いいねの数が0のものを取得
  scope :with_likes_count_all, lambda { |user|
    user_posts = where(user_id: user.id).left_joins(:likes).where(likes: { user_id: nil })
    open_posts = where(privacy: 'open')
                 .where.not(user_id: user.id)
                 .left_joins(:likes)
                 .group('posts.id')
                 .having(
                   'COUNT(likes.id) = 0 OR
                      (COUNT(likes.id) = 1 AND
                      SUM(CASE WHEN likes.user_id = posts.user_id THEN 1 ELSE 0 END) = 0)'
                 )
    user_posts.or(open_posts)
  }

  # スコープ: 自分以外のユーザーの公開設定された投稿を、いいねの数が0（投稿した本人のいいねを除く）で取得
  scope :public_likes_chance, lambda { |user|
    where.not(user_id: user.id)
         .where(privacy: 'open')
         .left_joins(:likes)
         .group('posts.id')
         .having(
           'COUNT(likes.id) = 0 OR
            (COUNT(likes.id) = 1 AND
            SUM(CASE WHEN likes.user_id = posts.user_id THEN 1 ELSE 0 END) = 0)'
         )
  }

  # スコープ: 自分だけの投稿を取得
  scope :only_me, -> { where(privacy: 'only_me') }

  # スコープ: 公開設定された自分の投稿を取得
  scope :my_posts_open, -> { where(privacy: 'open') }
end

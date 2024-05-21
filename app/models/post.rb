class Post < ApplicationRecord
  extend ActiveRecordExtended::QueryMethods

  belongs_to :user
  has_many :replies, class_name: 'Post', foreign_key: :post_reply_id, dependent: :destroy, inverse_of: :parent_post
  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_reply_id, optional: true, inverse_of: :replies

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3599 },
                       allow_nil: true

  enum privacy: { only_me: 0, friends_only: 1, open: 2 }

  # 公開設定の投稿を表示するスコープ
  scope :visible_to, ->(user) { where(privacy: %i[open friends_only]).or(where(user:)) }

  # ユーザーがいいねしていない投稿を取得するスコープ
  scope :not_liked_by_user, lambda { |user|
    where(user_id: user.id).left_joins(:likes).where(likes: { user_id: nil })
  }

  # 自分の投稿で自分がいいねしていないもの、および他のユーザーの公開設定された投稿で、
  # そのユーザー自身がいいねしていない、いいねの数が0のものを取得するスコープ
  scope :with_likes_count_all, lambda { |user|
    user_posts = where(user_id: user.id).left_joins(:likes).where(likes: { user_id: nil })
    open_posts = where(privacy: 'open')
                 .where.not(user_id: user.id)
                 .where.missing(:likes)
    user_posts.or(open_posts)
  }

  # 自分以外のユーザーの公開設定された投稿を、いいねの数が0（投稿した本人のいいねを除く）で取得するスコープ
  scope :public_likes_chance, lambda { |user|
    where.not(user_id: user.id)
         .where(privacy: 'open')
         .where.missing(:likes)
  }

  # 自分だけの投稿を取得するスコープ
  scope :only_me, -> { where(privacy: 'only_me') }

  # 公開設定された自分の投稿を取得するスコープ
  scope :my_posts_open, -> { where(privacy: 'open') }
end

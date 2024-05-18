class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  # Active Storageを使って添付ファイルを管理する
  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }

  # 録音時間が59分59秒（3599秒）以下であることを保証するバリデーション
  # nilの許可
  validates :duration,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3599 },
            allow_nil: true

  # 投稿のプライバシーレベル
  enum privacy: { only_me: 0, friends_only: 1, open: 2 }

  scope :visible_to, lambda { |user|
    where(privacy: %i[open friends_only]).or(where(user:))
  }

  # 自分がいいねをしていない自分の投稿
  scope :not_liked_by_user, ->(user) {
    where(user_id: user.id).left_joins(:likes).where(likes: { user_id: nil })
  }

  # みんなの投稿で0または1のいいねが付いているもの
  scope :with_likes_count, -> {
    left_joins(:likes).group('posts.id').having('COUNT(likes.id) <= 1')
  }
end

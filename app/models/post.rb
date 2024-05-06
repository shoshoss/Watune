class Post < ApplicationRecord
  belongs_to :user

  # Active Storageを使って添付ファイルを管理する
  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }

  # 録音時間を秒単位で保存する属性
  attribute :duration, :integer

  # 録音時間が59分59秒（3599秒）以下であることを保証するバリデーション
  validates :duration,
            numericality: { less_than_or_equal_to: 3599 }

  # 投稿のプライバシーレベル
  enum privacy: { only_me: 0, friends_only: 1, open: 2 }
end

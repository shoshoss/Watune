class Post < ApplicationRecord
  belongs_to :user

  # アップローダーを関連付け
  mount_uploader :audio, AudioUploader

  validates :body, length: { maximum: 10_000 }

  enum privacy: { only_me: 0, friends_only: 1, open: 2 }
end

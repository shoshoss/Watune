class Post < ApplicationRecord
  enum privacy: { only_me: 0, friends_only: 1, open: 2 }

  belongs_to :user

  # 最大1万文字
  validates :content, length: { maximum: 10_000 }
end

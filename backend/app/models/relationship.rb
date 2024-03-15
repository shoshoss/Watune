class Relationship < ApplicationRecord
  # "follower" はフォローするユーザーを指し、User モデルからの参照。
  belongs_to :follower, class_name: 'User'
  # "followed" はフォローされるユーザーを指し、User モデルからの参照。
  belongs_to :followed, class_name: 'User'

  # フォロワーIDとフォロードIDの存在を検証。

  # ユーザーが同じユーザーを重複してフォローすることを防ぐためのバリデーション。
  # 一つのフォロワーは特定のフォロードに対して一つだけのリレーションシップを持てる。
  validates :follower_id, uniqueness: { scope: :followed_id }
end

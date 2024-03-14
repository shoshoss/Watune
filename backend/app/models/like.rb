class Like < ApplicationRecord
  # "user" はこの「いいね」を行ったユーザーへの参照。
  belongs_to :user
  # "post" はこの「いいね」がされた投稿への参照。
  belongs_to :post

  # ユーザーが同じ投稿に対して重複して「いいね」を行うことを防ぐためのバリデーション。
  # 各ユーザーは各投稿に対して一つだけの「いいね」を持てる。
  validates :user_id, uniqueness: { scope: :post_id }
end

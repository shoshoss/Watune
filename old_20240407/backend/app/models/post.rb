class Post < ApplicationRecord
  # この投稿を作成したユーザーとの関連。投稿は必ず一人のユーザーに属しています。
  belongs_to :user

  # この投稿に対する「いいね」の関連。投稿が削除された場合、関連する「いいね」もすべて削除されます。
  has_many :likes, dependent: :destroy

  # 投稿のプライバシーレベルをenumで定義。整数値とシンボルをマッピングしています。
  enum privacy: { myself_only: 0, friends_and_myself: 1, public_open: 2 }
end

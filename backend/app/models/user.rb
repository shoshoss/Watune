class User < ApplicationRecord
  # ユーザーが投稿した記事。ユーザーが削除されると、そのユーザーの投稿も全て削除される。
  has_many :posts, dependent: :destroy

  # ユーザーが「フォローしている」関係性。ユーザーが削除されると、そのユーザーがフォローしている関係性も全て削除される。
  # "Relationship" モデルを "active_relationships" として参照し、"follower_id" を外部キーとして使用。
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy

  # ユーザーを「フォローしている」関係性。ユーザーが削除されると、そのユーザーをフォローしている関係性も全て削除される。
  # "Relationship" モデルを "passive_relationships" として参照し、"followed_id" を外部キーとして使用。
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy

  # ユーザーがフォローしている他のユーザー。"active_relationships" を通じて、フォローしている（"followed"）ユーザーを取得。
  has_many :following, through: :active_relationships, source: :followed

  # ユーザーをフォローしている他のユーザー。"passive_relationships" を通じて、フォローしている（"follower"）ユーザーを取得。
  has_many :followers, through: :passive_relationships, source: :follower

  # ユーザーが行った「いいね」。ユーザーが削除されると、そのユーザーの「いいね」も全て削除される。
  has_many :likes, dependent: :destroy

  # パスワードの安全なハッシュ化と認証を可能にする。このためには、bcrypt gemが必要。
  has_secure_password

  # 投稿に「いいね」をする
  def like(post)
    likes.create(post_id: post.id)
  end

  # 投稿の「いいね」を解除する
  def unlike(post)
    likes.find_by(post_id: post.id).destroy
  end

  # 特定の投稿に対して「いいね」しているかどうかを確認する
  def like?(post)
    likes.exists?(post_id: post.id)
  end

  # 他のユーザーをフォローする
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id) unless self == other_user
  end

  # フォローを解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy if following?(other_user)
  end

  # 既に特定のユーザーをフォローしているかどうかを確認する
  def following?(other_user)
    following.include?(other_user)
  end
end

class Post < ApplicationRecord
  extend ActiveRecordExtended::QueryMethods

  belongs_to :user
  has_many :replies, class_name: 'Post', foreign_key: :post_reply_id, inverse_of: :parent_post
  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_reply_id, optional: true, inverse_of: :replies
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  has_many :post_users, dependent: :destroy
  has_many :direct_recipients, -> { where(post_users: { role: 'direct_recipient' }) }, through: :post_users, source: :user
  has_many :reply_recipients, -> { where(post_users: { role: 'reply_recipient' }) }, through: :post_users, source: :user
  has_many :community_recipients, -> { where(post_users: { role: 'community_recipient' }) }, through: :post_users, source: :user

  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3599 },
                       allow_nil: true

  enum privacy: { only_me: 0, reply: 1, open: 2, only_yours: 10, only_friends: 20, selected_users: 30, community: 40 }

  # 公開設定の投稿を表示するスコープ
  scope :visible_to, ->(user) {
    where(privacy: %i[open only_yours only_friends selected_users community]).or(where(user:))
  }

  # 投稿者本人が自分に「いいね」をしていない投稿を取得するスコープ
  scope :not_liked_by_user, ->(user) {
    where(user_id: user.id)
      .where.not(id: Like.select(:post_id).where(user_id: user.id))
      .order(created_at: :asc)
  }

  # 自分の投稿で自分が応援していないもの、および他のユーザーの公開設定された投稿で、
  # 応援の数が0から9の範囲に収まるものを取得するスコープ
  scope :with_likes_count_all, ->(user) {
    user_posts = where(user_id: user.id)
                 .left_joins(:likes)
                 .group('posts.id')
                 .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
                 .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
                 .order(created_at: :asc)

    open_posts = where.not(user_id: user.id)
                      .where(privacy: 'open')
                      .left_joins(:likes)
                      .group('posts.id')
                      .having('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) <= 9')
                      .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
                      .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
                      .order(created_at: :asc)

    user_posts.or(open_posts)
  }

  # 自分以外のユーザーの公開設定された投稿を、投稿者本人の応援を除外して応援の数が0から9のものに限定して取得するスコープ
  scope :public_likes_chance, ->(user) {
    where.not(user_id: user.id)
         .where(privacy: 'open')
         .left_joins(:likes)
         .group('posts.id')
         .having('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) <= 9')
         .having('SUM(CASE WHEN likes.user_id = ? THEN 1 ELSE 0 END) = 0', user.id)
         .order(Arel.sql('SUM(CASE WHEN likes.user_id = posts.user_id THEN 0 ELSE 1 END) ASC'))
         .order(created_at: :asc)
  }

  # 自分だけの投稿を取得するスコープ
  scope :only_me, -> { where(privacy: 'only_me').order(created_at: :desc) }

  # 公開設定された自分の投稿を取得するスコープ
  scope :my_posts_open, -> { where(privacy: 'open').order(created_at: :desc) }

  # 仲間への投稿を取得するスコープ
  scope :my_posts_following, ->(user) { joins(:post_users).where(post_users: { user_id: user.following_ids, role: 'direct_recipient' }).order(created_at: :desc) }

  # 仲間からの投稿を取得するスコープ
  scope :posts_to_you, ->(user) { joins(:post_users).where(post_users: { user_id: user.following_ids, role: 'direct_recipient' }).order(created_at: :desc) }

  # 親の投稿のユーザー名が重複しないように祖先を取得するメソッド
  def ancestors
    parents = []
    current_post = self
    while current_post.parent_post
      parents << current_post.parent_post
      current_post = current_post.parent_post
    end
    parents.reverse
  end
end

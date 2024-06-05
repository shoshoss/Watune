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
  has_many :direct_recipients, lambda {
                                 where(post_users: { role: 'direct_recipient' })
                               }, through: :post_users, source: :user
  has_many :community_recipients, lambda {
                                    where(post_users: { role: 'community_recipient' })
                                  }, through: :post_users, source: :user

  has_one_attached :audio

  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3599 },
                       allow_nil: true

  enum privacy: { only_me: 0, reply: 1, open: 2, selected_users: 10, community: 20, only_direct: 30 }

  # 公開設定の投稿を表示するスコープ
  def visible_to?(user)
    return true if self.user == user # 投稿者本人
    return true if privacy == 'open' # 全体公開
    return true if privacy == 'reply'

    post_users.exists?(user:, approved: true) # 承認された受信者
  end

  # 投稿者本人が自分に「いいね」をしていない投稿を取得するスコープ
  scope :not_liked_by_user, lambda { |user|
    where(user_id: user.id)
      .where.not(id: Like.select(:post_id).where(user_id: user.id))
      .order(created_at: :asc)
  }

  # 自分の投稿で自分が応援していないもの、および他のユーザーの公開設定された投稿で、
  # 応援の数が0から9の範囲に収まるものを取得するスコープ
  scope :with_likes_count_all, lambda { |user|
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
  scope :public_likes_chance, lambda { |user|
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
  scope :my_posts_following, lambda { |user|
    direct_posts = joins(:post_users).where(
      user:,
      post_users: { role: 'direct_recipient' }
    )
    reply_posts = where(user_id: user.id, post_reply_id: Post.select(:id))

    Post.where(id: direct_posts.select(:id))
        .or(Post.where(id: reply_posts.select(:id)))
        .distinct.order(created_at: :desc)
  }

  # 仲間からの投稿を取得するスコープ
  scope :posts_to_you, lambda { |user|
    direct_posts = joins(:post_users).where(
      post_users: { user_id: user, role: 'direct_recipient' }
    )
    reply_posts = where(post_reply_id: Post.where(user_id: user).select(:id))

    Post.where(id: direct_posts.select(:id))
        .or(Post.where(id: reply_posts.select(:id)))
        .distinct.order(created_at: :desc)
  }

  # 相互のダイレクトメッセージや複数選択の送受信、返信のやり取りを表示するスコープ
  scope :shared_with_you, lambda { |current_user, profile_user|
    direct_to_profile_user = joins(:post_users).where(
      user_id: current_user.id,
      post_users: { user_id: profile_user.id, role: 'direct_recipient', approved: true }
    )
    direct_to_current_user = joins(:post_users).where(
      user_id: profile_user.id,
      post_users: { user_id: current_user.id, role: 'direct_recipient', approved: true }
    )
    reply_from_current_user = where(
      user_id: current_user.id,
      post_reply_id: Post.where(user_id: profile_user.id).select(:id)
    )
    reply_from_profile_user = where(
      user_id: profile_user.id,
      post_reply_id: Post.where(user_id: current_user.id).select(:id)
    )

    Post.where(id: direct_to_profile_user.select(:id))
        .or(Post.where(id: direct_to_current_user.select(:id)))
        .or(Post.where(id: reply_from_current_user.select(:id)))
        .or(Post.where(id: reply_from_profile_user.select(:id)))
        .distinct.order(created_at: :desc)
  }

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

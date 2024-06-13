class Post < ApplicationRecord
  include Posts::LikeScopes
  include Posts::UserPostScopes
  include Posts::SharedScopes
  include Posts::Notification

  attr_accessor :recipient_ids

  # ユーザーとの関係
  belongs_to :user

  # リプライ関係
  has_many :replies, class_name: 'Post', foreign_key: :post_reply_id, inverse_of: :parent_post
  belongs_to :parent_post, class_name: 'Post', foreign_key: :post_reply_id, optional: true, inverse_of: :replies

  # いいね関係
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  # ブックマーク関係
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  # 投稿とユーザーの関係
  has_many :post_users, dependent: :destroy
  has_many :direct_recipients, lambda {
                                 where(post_users: { role: 'direct_recipient' })
                               }, through: :post_users, source: :user
  has_many :community_recipients, lambda {
                                    where(post_users: { role: 'community_recipient' })
                                  }, through: :post_users, source: :user

  # リポスト関係
  has_many :reposts, dependent: :destroy
  has_many :reposted_by_users, through: :reposts, source: :user

  # 音声添付ファイル
  has_one_attached :audio

  # バリデーション
  validates :body, length: { maximum: 10_000 }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_thanまたはequal_to: 3599 },
                       allow_nil: true

  # プライバシー設定
  enum privacy: { only_me: 0, reply: 1, open: 2, selected_users: 10, community: 20, only_direct: 30 }

  # 投稿の可視性を判定するメソッド
  def visible_to?(user)
    return true if self.user == user # 投稿者本人
    return true if privacy == 'open' # 全体公開
    return true if privacy == 'reply' # リプライ

    post_users.exists?(user:, approved: true) # 承認された受信者
  end

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

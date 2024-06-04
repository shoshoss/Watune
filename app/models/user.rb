class User < ApplicationRecord
  # Sorceryによる認証機能を有効化
  authenticates_with_sorcery!

  # 認証情報を複数保持するための関連付け。ユーザー削除時に認証情報も削除される。
  has_many :authentications, dependent: :destroy

  # UserとPostの関連付け
  has_many :posts, dependent: :destroy

  has_many :posts
  has_many :post_users, through: :posts
  has_many :friendships, foreign_key: :follower_id
  has_many :followings, through: :friendships, source: :followed

  def following_ordered_by_sent_posts
    following_ids = followings.pluck(:id)

    # フォローしているユーザーの送信回数を取得
    user_post_counts = PostUser.where(user_id: following_ids)
                               .group(:user_id)
                               .count

    # 全フォローしているユーザーを取得
    followings_with_counts = followings.map do |user|
      [user, user_post_counts[user.id] || 0]
    end

    # 送信回数でソート
    followings_with_counts.sort_by { |_, count| -count }.map(&:first)
  end

  # ネストされた属性として認証情報を受け入れる
  accepts_nested_attributes_for :authentications

  # Active Storageを使って添付ファイルを管理する
  has_one_attached :avatar

  # 応援機能
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  # ブックマーク機能
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_posts, through: :bookmarks, source: :post

  # フォロー・フォロワー機能の関連付け
  has_many :active_friendships, class_name: 'Friendship', foreign_key: :follower_id, dependent: :destroy,
                                inverse_of: :follower
  has_many :passive_friendships, class_name: 'Friendship', foreign_key: :followed_id, dependent: :destroy,
                                 inverse_of: :followed
  has_many :followings, through: :active_friendships, source: :followed
  has_many :followers, through: :passive_friendships, source: :follower

  # バリデーションの定義
  validates :email, uniqueness: true, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 8, message: :too_short },
                       if: -> { new_record? || changes[:crypted_password] }
  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true

  # 予約されたusername_slugを設定
  RESERVED_USERNAMES = %w[
    admin support blog home user dashboard privacy_policy terms_of_use
    privacy_modal tou_modal signup_modal signup oauth login logout
    login_modal password_resets posts profile explore notification
    notifications message messages lists bookmarks communities
    premium_sign_up setting settings start spaces job jobs following
    followings follow follows follower followers verified_followers
    api about top help faq terms privacy register search account
    subscribe billing download feed audio modal movie movies film
    films image images photo photos photograph photographs picture pictures
  ].freeze

  # 表示名は最大50文字
  validates :display_name, length: { maximum: 50 }
  validates :username_slug, presence: true, uniqueness: { case_sensitive: false, message: :taken },
                            length: { minimum: 3, maximum: 15, too_short: :too_short, too_long: :too_long },
                            format: { with: /\A[\w]+\z/, message: :invalid_format },
                            exclusion: { in: RESERVED_USERNAMES, message: :reserved }
  validates :self_introduction, length: { maximum: 500 }

  # コールバック
  before_validation :generate_username_slug, on: :create, unless: :username_slug?
  after_create :set_default_display_name

  # スコープ ログインしているユーザーがフォローしているユーザーを除外して、新規ユーザーを表示
  def self.recently_registered(current_user = nil)
    users = where(guest: false)
    users = users.where.not(id: current_user.followings.pluck(:id) + [current_user.id]) if current_user
    users.order(created_at: :desc).limit(5)
  end

  # enumでユーザーの役割を定義：一般ユーザーは0、管理者は1
  enum role: { general: 0, admin: 1 }

  # インスタンスメソッド
  def like(post)
    likes.create(post:)
  end

  def unlike(post)
    likes.find_by(post:)&.destroy
  end

  def like?(post)
    likes.exists?(post:)
  end

  def bookmark(post)
    bookmarks.create(post:)
  end

  def unbookmark(post)
    bookmarks.find_by(post:)&.destroy
  end

  def bookmarked?(post)
    bookmarks.exists?(post:)
  end

  def following?(user)
    active_friendships.exists?(followed_id: user.id)
  end

  def follow(user)
    active_friendships.find_or_create_by!(followed_id: user.id)
  end

  def unfollow(user)
    friendship = active_friendships.find_by(followed_id: user.id)
    friendship&.destroy!
  end

  def own?(object)
    id == object&.user_id
  end

  # ゲストユーザーかどうかを確認するメソッド
  def guest?
    guest
  end

  private

  # ユーザー名スラグを生成するメソッド
  def generate_username_slug
    return if username_slug.present?

    loop do
      # 3文字以上、15文字以内のランダムな文字列を生成
      self.username_slug = SecureRandom.alphanumeric(rand(3..15)).downcase
      break unless User.exists?(username_slug:)
    end
  end

  # デフォルトの表示名を設定するメソッド
  def set_default_display_name
    update(display_name: "ウェーブ登録#{id}") if display_name.blank?
  end

  # フォロー中のユーザーを送信回数で並び替えるスコープ
  scope :following_ordered_by_sent_posts, ->(user_id) {
    joins(:post_users)
      .where(post_users: { role: 'direct_recipient' })
      .where(posts: { user_id: user_id })
      .group('users.id')
      .order('COUNT(posts.id) DESC')
  }
end

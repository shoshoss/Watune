class User < ApplicationRecord
  # Sorceryによる認証機能を有効化
  authenticates_with_sorcery!
  # 認証情報を複数保持するための関連付け。ユーザー削除時に認証情報も削除される。
  has_many :authentications, dependent: :destroy

  # UserとPostの関連付け
  has_many :posts, dependent: :destroy

  # Active Storageを使って添付ファイルを管理する
  has_one_attached :avatar

  # ネストされた属性として認証情報を受け入れる
  accepts_nested_attributes_for :authentications
  before_validation :generate_username_slug, on: :create, unless: :username_slug?
  after_create :set_default_display_name

  # メールアドレスは一意であり、存在が必要で、最大255文字
  validates :email, uniqueness: true, presence: true, length: { maximum: 255 }

  # パスワードは新規作成または変更時に8文字以上
  validates :password,
  presence: true,
  length: { minimum: 8, message: :too_short },
  if: -> { new_record? || changes[:crypted_password] }
  
  # リセットパスワードトークンは一意であり、存在することも許可される
  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true
  
  # 表示名は最大50文字
  validates :display_name, length: { maximum: 50 }
  
  # ゲストユーザーを除外して新規登録者を取得
  scope :recently_registered, -> { where(guest: false).order(created_at: :desc).limit(15) }
  
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

  # ユーザー名スラグは一意で、15文字以下、特定の形式に従う必要がある
  validates :username_slug, presence: true,
                            uniqueness: { case_sensitive: false, message: :taken },
                            length: { minimum: 3, maximum: 15, too_short: :too_short, too_long: :too_long },
                            format: { with: /\A[\w]+\z/, message: :invalid_format },
                            exclusion: { in: RESERVED_USERNAMES, message: :reserved }

  # 自己紹介は最大500文字まで
  validates :self_introduction, length: { maximum: 500 }

  # 応援機能
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  def like(post)
    likes.create(post:)
  end

  def unlike(post)
    likes.find_by(post:)&.destroy
  end

  def like?(post)
    likes.exists?(post:)
  end

  # ブックマーク機能
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_posts, through: :bookmarks, source: :post

  def bookmark(post)
    bookmarks.create(post:)
  end

  def unbookmark(post)
    bookmarks.find_by(post:)&.destroy
  end

  def bookmarked?(post)
    bookmarks.exists?(post:)
  end


  # ユーザーの役割をenumで定義：一般ユーザーは0、管理者は1
  enum role: { general: 0, admin: 1 }

  # ユーザーが引数で渡されたリソースの所有者かどうかを判断するメソッド
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
end

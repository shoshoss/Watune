class User < ApplicationRecord
  include Users::Likes
  include Users::Bookmarks
  include Users::Follows
  include Users::Reposts

  # Sorceryによる認証機能を有効化
  authenticates_with_sorcery!

  # 通知設定のデフォルト値を設定するためのコールバック
  after_initialize :set_default_notification_settings, if: :new_record?

  # 関連付け
  has_many :authentications, dependent: :destroy # 認証情報を複数保持
  has_many :posts, dependent: :destroy # 投稿と関連付け
  has_many :post_users, through: :posts # 投稿ユーザーと関連付け
  has_many :sent_notifications, class_name: 'Notification', foreign_key: 'sender_id', dependent: :destroy,
                                inverse_of: :sender # 送信された通知
  has_many :received_notifications, class_name: 'Notification', foreign_key: 'recipient_id', dependent: :destroy,
                                    inverse_of: :recipient # 受信した通知

  # ファイル添付
  has_one_attached :avatar # アバター画像

  # バリデーションの定義
  validates :email, uniqueness: true, presence: true, length: { maximum: 255 } # メールアドレス
  validates :password, presence: true, length: { minimum: 8, message: :too_short },
                       if: -> { new_record? || changes[:crypted_password] } # パスワード
  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true # パスワードリセットトークン
  validates :display_name, length: { maximum: 50 } # 表示名は最大50文字

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

  validates :username_slug, presence: true, uniqueness: { case_sensitive: false, message: :taken },
                            length: { minimum: 3, maximum: 15, too_short: :too_short, too_long: :too_long },
                            format: { with: /\A[\w]+\z/, message: :invalid_format },
                            exclusion: { in: RESERVED_USERNAMES, message: :reserved } # ユーザー名スラグ
  validates :self_introduction, length: { maximum: 500 } # 自己紹介文

  # コールバック
  before_validation :generate_username_slug, on: :create, unless: :username_slug? # ユーザー名スラグを生成
  after_create :set_default_display_name # デフォルトの表示名を設定

  # enumでユーザーの役割を定義：一般ユーザーは0、管理者は1
  enum role: { general: 0, admin: 1 }

  # スコープ: ログインしているユーザーがフォローしているユーザーを除外して、新規ユーザーを表示
  def self.recently_registered(current_user = nil)
    users = where(guest: false)
    users = users.where.not(id: current_user.followings.pluck(:id) + [current_user.id]) if current_user
    users.order(created_at: :desc)
  end

  # オブジェクトがユーザー自身のものであるかどうかを確認
  def own?(object)
    id == object&.user_id
  end

  # ゲストユーザーかどうかを確認
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
    update(display_name: "ウェーチュン登録#{id}") if display_name.blank?
  end

  # 通知設定のデフォルト値を設定するメソッド
  def set_default_notification_settings
    self.email_notify_on_reply = true if email_notify_on_reply.nil?
    self.email_notify_on_direct_message = true if email_notify_on_direct_message.nil?
  end
end

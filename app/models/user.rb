class User < ApplicationRecord
  # Sorceryによる認証機能を有効化
  authenticates_with_sorcery!
  # 認証情報を複数保持するための関連付け。ユーザー削除時に認証情報も削除される。
  has_many :authentications, dependent: :destroy
  # ネストされた属性として認証情報を受け入れる
  accepts_nested_attributes_for :authentications

  attr_accessor :external_auth # 外部認証フラグを追加

  has_secure_password validations: false # バリデーションを手動で制御

  validates :password, presence: true, confirmation: true, if: :password_required?

  # ユーザー作成時にユーザー名スラグを自動生成する
  before_validation :generate_username_slug, on: :create

  # メールアドレスは一意であり、存在が必要で、最大255文字
  validates :email, uniqueness: true, presence: true, length: { maximum: 255 }

 # パスワードは新規作成または変更時に8文字以上であり、かつ半角英数字を含む必要がある
  validates :password, length: { minimum: 8 }, format: { with: /\A[a-zA-Z0-9]+\z/, message: "は半角英数字である必要があります" }, if: -> { new_record? || changes[:crypted_password] }

  # パスワードの確認が必要
  # validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

  # パスワード確認フィールドの存在確認
  # validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  # リセットパスワードトークンは一意であり、存在することも許可される
  # validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true

  # 最大50文字
  # validates :display_name, length: { maximum: 50 }

  # ユーザー名スラグは一意で、15文字以下、特定の形式に従う必要がある
  validates :username_slug, presence: true, uniqueness: true,
                            length: { minimum: 3, maximum: 15 },
                            format: { with: /\A[\w]+\z/ }

  # 自己紹介は最大500文字まで
  # validates :self_introduction, length: { maximum: 500 }

  # アバターURLはURL形式で、存在しなくても良い
  # validates :avatar_url, url: true, allow_blank: true

  # ユーザーの役割をenumで定義：一般ユーザーは0、管理者は1
  enum role: { general: 0, admin: 1 }

  # アバター画像のアップローダーをマウント
  # mount_uploader :avatar, AvatarUploader

  private

  def password_required?
    # 外部認証がtrueで、かつパスワードが存在しない、または確認用のパスワードが存在しない場合は、
    # パスワードのバリデーションはスキップする
    return false if external_auth && password.blank? && password_confirmation.blank?

    # 新規レコードであるか、パスワードまたはパスワード確認フィールドが存在する場合は
    # バリデーションが必要
    new_record? || password.present? || password_confirmation.present?
  end

  def generate_username_slug
    return if username_slug.present?

    loop do
      # 3文字以上、15文字以内のランダムな文字列を生成
      self.username_slug = SecureRandom.alphanumeric(rand(3..15)).downcase
      break unless User.exists?(username_slug:)
    end
  end
end

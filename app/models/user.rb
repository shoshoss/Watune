class User < ApplicationRecord
  authenticates_with_sorcery!
end
class User < ApplicationRecord
  # Sorceryによる認証機能を有効化
  authenticates_with_sorcery!

  # メールアドレスは一意であり、存在が必要で、最大255文字
  validates :email, uniqueness: true, presence: true, length: { maximum: 255 }
  
  # パスワードは新規作成または変更時に8文字以上必要
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  
  # パスワードの確認が必要
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  
  # パスワード確認フィールドの存在確認
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  
  # リセットパスワードトークンは一意であり、存在することも許可される
  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true
  
  # 表示名は存在が必要で、最大50文字
  validates :display_name, presence: true, length: { maximum: 50 }
  
  # ユーザー名スラグは一意で、15文字以下、特定の形式に従う必要がある
  validates :username_slug, uniqueness: true, presence: true, length: { maximum: 15 },
            format: { with: /\A[a-zA-Z_][a-zA-Z0-9_]*\z/,
                      message: 'must start with a letter and contain only letters, digits, and underscores' }
  
  # 自己紹介は最大500文字まで
  validates :self_introduction, length: { maximum: 500 }
  
  # アバターURLはURL形式で、存在しなくても良い
  validates :avatar_url, url: true, allow_blank: true

  # ユーザーの役割をenumで定義：一般ユーザーは0、管理者は1
  enum role: { general: 0, admin: 1 }

  # アバター画像のアップローダーをマウント
  mount_uploader :avatar_url, AvatarUploader
end

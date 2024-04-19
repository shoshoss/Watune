class Authentication < ApplicationRecord
  # ユーザーモデルへの属する関係を定義
  belongs_to :user

  # 必須フィールドとしてproviderとuidの存在を保証
  # validates :provider, presence: true
  # validates :uid, presence: true, uniqueness: { scope: :provider }

  # providerとuidの組み合わせがユニークであることを保証
  # validates :uid, uniqueness: { scope: :provider }
end

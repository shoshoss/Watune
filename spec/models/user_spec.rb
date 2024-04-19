require 'rails_helper'

RSpec.describe User do
  it 'メールがあり、パスワードは半角英数・8文字以上であれば有効であること' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'メールはユニークであること' do
    user1 = create(:user)
    user2 = build(:user)
    user2.email = user1.email
    user2.valid? # 同じメールアドレスを持つ他のユーザーがすでに存在する場合、エラーメッセージが生成
    expect(user2.errors[:email]).to include('has already been taken')
  end

  it 'メールアドレスは必須項目であること' do
    user = build(:user)
    user.email = nil
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end
end

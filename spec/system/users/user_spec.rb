require 'rails_helper'

RSpec.describe 'ユーザー登録' do
  context '入力情報正常系' do
    it 'ユーザーが新規作成できること' do
      visit '/'
      click_link('新規登録')
      expect do
        fill_in 'メールアドレス', with: 'example@example.com'
        fill_in 'パスワード', with: 'a12345678'
        click_button '登録'
        Capybara.assert_current_path('/profile/edit', ignore_query: true)
      end.to change(User, :count).by(1)
    end
  end

  context '入力情報異常系' do
    it 'ユーザーが新規作成できない' do
      visit '/'
      click_link('新規登録')
      expect do
        fill_in 'メールアドレス', with: 'example@example.com'
        click_button '登録'
      end.not_to(change(User, :count))
    end
  end
end

require 'rails_helper'

RSpec.describe 'パスワードリセット' do
  let(:user) { create(:user) }

  describe 'タイトル' do
    describe 'パスワードリセット申請ページ' do
      it '正しいタイトルが表示されていること' do
        visit new_password_reset_path
        expect(page).to have_title('パスワードリセット申請'), 'パスワードリセット申請ページのタイトルに「パスワードリセット申請」が含まれていません'
      end
    end

    describe 'パスワードリセットページ' do
      it '正しいタイトルが表示されていること' do
        user.generate_reset_password_token!
        visit edit_password_reset_path(user.reset_password_token)
        expect(page).to have_title('パスワードリセット'), 'パスワードリセットページのタイトルに「パスワードリセット」が含まれていません'
      end
    end
  end

  describe 'パスワードが変更できる' do
    before do
      visit new_password_reset_path
      fill_in 'メールアドレス', with: user.email
      click_button '送信'
    end

    it '適切なフラッシュメッセージが表示されること' do
      expect(page).to have_content('パスワードリセット手順を送信しました')
    end

    it 'パスワードを変更後、ログインページにリダイレクトする' do
      user.generate_reset_password_token!
      visit edit_password_reset_path(user.reload.reset_password_token)
      fill_in 'パスワード', with: 'a123456789'
      click_button '更新'
      expect(page).to have_current_path(login_path, ignore_query: true)
      expect(page).to have_content('パスワードを変更しました')
    end
  end
end

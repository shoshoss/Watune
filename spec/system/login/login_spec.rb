require 'rails_helper'

RSpec.describe 'ログイン・ログアウト' do
  let(:user) { create(:user) }

  describe '通常画面' do
    describe 'ログイン' do
      context '認証情報が正しい場合' do
        it 'ログインできること' do
          visit '/login'
          fill_in 'メールアドレス', with: user.email
          fill_in 'パスワード', with: 'a12345678'
          click_button 'ログイン'
          Capybara.assert_current_path('/', ignore_query: true)
          expect(page).to have_current_path root_path, ignore_query: true
        end
      end

      context 'PWに誤りがある場合' do
        it 'ログインできないこと' do
          visit '/'
          click_link('ログイン')
          fill_in 'メールアドレス', with: user.email
          fill_in 'パスワード', with: '1234'
          click_button 'ログイン'
          expect(page).to have_current_path('/login'), 'ログイン失敗時にログイン画面に戻ってきていません'
        end
      end
    end

    describe 'ログアウト' do
      before do
        login_as_general
      end

      it 'ログアウトできること' do
        # find('#header-profile').click
        click_link('ログアウト')
        expect(page).to have_current_path root_path, ignore_query: true
      end
    end
  end
end

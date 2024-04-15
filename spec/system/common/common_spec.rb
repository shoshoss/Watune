require 'rails_helper'

RSpec.describe '共通系', type: :system do
  before do
    visit root_path
  end
  describe 'ヘッダー' do
    it 'ヘッダーが正しく表示されていること' do
      expect(page).to have_content('ホーム'), 'ヘッダーに「ホーム」というテキストが表示されていません'
      expect(page).to have_content('みんなのWave'), 'ヘッダーに「みんなのWave」というテキストが表示されていません'
      expect(page).to have_content('ログイン'), 'ヘッダーに「ログイン」というテキストが表示されていません'
      expect(page).to have_content('新規登録'), 'ヘッダーに「新規作成」というテキストが表示されていません'
    end
  end

  describe 'フッター' do
    it 'フッターが正しく表示されていること' do
      expect(page).to have_content('Copyright'), '「Copyright」というテキストが表示されていません'
    end
  end
end

require 'rails_helper'

RSpec.describe '共通系' do
  before do
    visit root_path
  end

  describe 'ヘッダー' do
    it 'ホームリンクが表示されていること' do
      expect(page).to have_content('ホーム'), 'ヘッダーに「ホーム」というテキストが表示されていません'
    end

    it 'みんなのWaveリンクが表示されていること' do
      expect(page).to have_content('みんなのWave'), 'ヘッダーに「みんなのWave」というテキストが表示されていません'
    end

    it 'ログインリンクが表示されていること' do
      expect(page).to have_content('ログイン'), 'ヘッダーに「ログイン」というテキストが表示されていません'
    end

    it '新規登録リンクが表示されていること' do
      expect(page).to have_content('新規登録'), 'ヘッダーに「新規登録」というテキストが表示されていません'
    end
  end

  describe 'フッター' do
    it '著作権情報が正しく表示されていること' do
      expect(page).to have_content('Copyright'), '「Copyright」というテキストが表示されていません'
    end
  end
end

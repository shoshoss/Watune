require 'rails_helper'

RSpec.describe UsersController do
  describe 'GET #new' do
    it 'HTTPを成功を返す' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'ユーザーを作成してプロフィール編集画面へ' do
      post :create, params: { user: { email: 'example@example.com', password: 'a12345678' } }
      expect(response).to redirect_to('/profile/edit')
      expect(response).to have_http_status(:see_other)
    end
  end
end

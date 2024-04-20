require 'rails_helper'

RSpec.describe UserSessionsController do
  let(:user) { create(:user, password: 'a12345678') }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #new' do
    it 'HTTP成功を返す' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context '認証情報が正しい場合' do
      before do
        post :create, params: { email: user.email, password: 'a12345678' }
      end

      it 'リダイレクトされること' do
        expect(response).to redirect_to(root_path)
      end

      it '適切なHTTPステータスコードを返すこと' do
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy
    end

    it '適切なHTTPステータスコードを返すこと' do
      expect(response).to have_http_status(:see_other) # 303 See Other
    end

    it 'ルートパスにリダイレクトされること' do
      expect(response).to redirect_to(root_path)
    end

    it 'セッションからユーザーIDが削除されていること' do
      expect(session[:user_id]).to be_nil
    end
  end
end

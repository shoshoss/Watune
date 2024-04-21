RSpec.describe PasswordResetsController do
  describe 'GET #new' do
    it 'HTTP成功を返す' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, email: 'test@example.com') }

    context 'when メールアドレスが存在する場合' do
      it 'パスワードリセットの指示を送信する' do
        allow(User).to receive(:find_by).with(email: 'test@example.com').and_return(user)
        allow(user).to receive(:deliver_reset_password_instructions!)
        post :create, params: { email: 'test@example.com' }
        expect(response).to redirect_to(login_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq I18n.t('password_resets.create.success')
      end
    end

    context 'when メールアドレスが存在しない場合' do
      it 'パスワードリセットの指示を送らずにリダイレクトする' do
        allow(User).to receive(:find_by).with(email: 'unknown@example.com').and_return(nil)
        post :create, params: { email: 'unknown@example.com' }
        expect(response).to redirect_to(login_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq I18n.t('password_resets.create.success')
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:token) { 'valid_token' }

    context 'when トークンが有効な場合' do
      it '編集テンプレートをレンダリングする' do
        allow(User).to receive(:load_from_reset_password_token).with(token).and_return(user)
        get :edit, params: { id: token }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when トークンが無効な場合' do
      it '認証されていないとしてリダイレクトする' do
        allow(User).to receive(:load_from_reset_password_token).with(token).and_return(nil)
        get :edit, params: { id: token }
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:token) { 'valid_token' }

    context 'when パラメータが有効な場合' do
      it 'ユーザーのパスワードを更新してリダイレクトする' do
        allow(User).to receive(:load_from_reset_password_token).with(token).and_return(user)
        allow(user).to receive(:change_password).and_return(true)

        patch :update, params: { id: token, user: { password: 'newpassword123' } }
        expect(response).to redirect_to(login_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq I18n.t('password_resets.update.success')
      end
    end

    context 'when パラメータが無効な場合' do
      it 'パスワードの更新に失敗し、編集テンプレートを再レンダリングする' do
        allow(User).to receive(:load_from_reset_password_token).with(token).and_return(user)
        allow(user).to receive(:change_password).and_return(false)

        patch :update, params: { id: token, user: { password: 'newpassword123' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to eq I18n.t('password_resets.update.fail')
      end
    end
  end
end

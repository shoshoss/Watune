class OauthsController < ApplicationController
  skip_before_action :require_login

  def oauth
    provider = params[:provider] || 'google'
    login_at(provider.to_sym)
    session[:provider] = provider
  end

  def callback
    provider = session.delete(:provider) || 'google'
    sorcery_fetch_user_hash(provider)

    @user = login_from(provider)
    if @user
      redirect_to root_path, notice: "#{provider.titleize} アカウントでログインしました"
    else
      @user = find_or_initialize_user(provider)
      is_new_user = @user.new_record? # 新規ユーザーかどうかを保存するフラグ
      setup_new_user(@user) if is_new_user
      reset_session
      auto_login(@user)
      redirect_path, notice_message = if is_new_user
                                        [edit_profile_path, "アカウントでユーザー登録に成功しました"]
                                      else
                                        [root_path, "アカウントでログインしました"]
                                      end
      redirect_to redirect_path, notice: "#{provider.titleize} #{notice_message}"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to login_path, alert: "アカウントの作成に失敗しました。エラー: #{e.message}"
  end

  private

  def find_or_initialize_user(provider)
    email = @user_hash[:user_info]['email']
    User.find_or_initialize_by(email: email)
  end

  def setup_new_user(user)
    user.assign_attributes(
      display_name: @user_hash[:user_info]['name'].presence || 'Default Name',
      external_auth: true
    )
    user.password = user.password_confirmation = SecureRandom.hex(10)
    user.save!
  end
end

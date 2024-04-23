class OauthsController < ApplicationController
  # ログインが不要なアクションについてはログイン要求をスキップ
  skip_before_action :require_login

  # OAuth認証を開始するアクション
  def oauth
    # プロバイダーをパラメータから取得、デフォルトは 'google'
    provider = params[:provider] || 'google'
    # Sorceryのlogin_atメソッドで認証ページにリダイレクト
    login_at(provider.to_sym)
    # プロバイダーをセッションに保存
    session[:provider] = provider
  end

  # OAuth認証からのコールバックを処理するアクション
  def callback
    # セッションからプロバイダーを取得し、削除
    provider = session.delete(:provider) || 'google'
    # プロバイダーからのデータを取得
    sorcery_fetch_user_hash(provider)

    # ユーザーでログインを試みる
    @user = login_from(provider)
    if @user
      # ログイン成功時、トップページにリダイレクト
      redirect_to root_path, status: :see_other, notice: 'ログインしました'
    else
      # ユーザーが見つからない場合、新規作成または初期化
      @user = find_or_initialize_user(provider)
      is_new_user = @user.new_record?
      # 新規ユーザーの場合、ユーザー情報を設定
      setup_new_user(@user) if is_new_user
      # セッションをリセットし、ユーザーでログイン
      reset_session
      auto_login(@user)
      # リダイレクト先と通知メッセージを決定
      redirect_path, notice_message = determine_redirect(is_new_user, provider)
      # 最終的なリダイレクトを実行
      redirect_to redirect_path, status: :see_other, notice: notice_message
    end
  rescue ActiveRecord::RecordInvalid => e
    # 保存失敗時はログインページにリダイレクトしエラーを表示
    flash[:error] = "アカウントの作成に失敗しました。エラー: #{e.message}"
    redirect_to login_path, status: :unprocessable_entity
  end

  private

  # プロバイダーからの情報に基づいてユーザーを検索または初期化
  def find_or_initialize_user(_provider)
    email = @user_hash[:user_info]['email']
    User.find_or_initialize_by(email:)
  end

  # 新規ユーザーの設定と保存を行う
  def setup_new_user(user)
    user.assign_attributes(
      display_name: @user_hash[:user_info]['name'].presence || 'Default Name',
      external_auth: true
    )
    user.password = SecureRandom.alphanumeric(10)
    user.save!
  end

  # リダイレクト先と通知メッセージを決定する
  def determine_redirect(is_new_user, _provider)
    if is_new_user
      [edit_profile_path, 'ユーザー登録に成功しました']
    else
      [root_path, 'ログインしました']
    end
  end
end

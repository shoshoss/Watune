class OauthsController < ApplicationController
  # ログインが必要ないアクションを設定
  skip_before_action :require_login

  # OAuth認証プロセスを開始するアクション
  def oauth
    # パラメータからプロバイダーを取得またはデフォルトで 'google' を設定
    provider = params[:provider] || 'google'
    # Sorceryのlogin_atメソッドを用いてプロバイダーの認証ページにリダイレクト
    login_at(provider.to_sym)
    # セッションにプロバイダーを保存
    session[:provider] = provider
  end

  # OAuth認証からのコールバックを処理するアクション
  def callback
    # セッションからプロバイダーを取得し、削除する
    provider = session.delete(:provider) || 'google'
    # プロバイダーからのデータを取得
    sorcery_fetch_user_hash(provider)

    # 既存のユーザーとしてログインを試みる
    @user = login_from(provider)
    if @user
      # ログインに成功した場合はトップページにリダイレクト
      redirect_to root_path, status: :see_other, notice: "#{provider.titleize} アカウントでログインしました"
    else
      # ユーザーが見つからない場合は、ユーザーを検索または初期化
      @user = find_or_initialize_user(provider)
      # 新規ユーザーかどうかを判定
      is_new_user = @user.new_record?
      # 新規ユーザーの場合、ユーザー情報の設定と保存
      setup_new_user(@user) if is_new_user
      # セッションをリセットし、ユーザーでログイン
      reset_session
      auto_login(@user)
      # リダイレクト先と通知メッセージを設定
      redirect_path, notice_message = if is_new_user
                                        [edit_profile_path, 'アカウントでユーザー登録に成功しました']
                                      else
                                        [root_path, 'アカウントでログインしました']
                                      end
      # リダイレクト実行
      redirect_to redirect_path, status: :see_other, notice: "#{provider.titleize} #{notice_message}"
    end
  rescue ActiveRecord::RecordInvalid => e
    # レコードの保存に失敗した場合はログインページにリダイレクト
    redirect_to login_path, status: :unprocessable_entity, error: "アカウントの作成に失敗しました。エラー: #{e.message}"
  end

  private

  # プロバイダーからの情報に基づいてユーザーを検索または初期化するメソッド
  def find_or_initialize_user(_provider)
    email = @user_hash[:user_info]['email']
    User.find_or_initialize_by(email:)
  end

  # 新規ユーザーの設定と保存を行うメソッド
  def setup_new_user(user)
    user.assign_attributes(
      display_name: @user_hash[:user_info]['name'].presence || 'Default Name',
      external_auth: true
    )
    user.password = SecureRandom.alphanumeric(10)
    user.save!
  end
end

require 'open-uri'
require 'tempfile'

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
      display_name: @user_hash[:user_info]['name'].presence || 'Default Name'
    )

    # アバターの添付とエラーハンドリング
    avatar_url = @user_hash[:user_info]['picture']
    if avatar_url.present?
      begin
        attach_avatar_from_url(user, avatar_url)
      rescue OpenURI::HTTPError => e
        Rails.logger.error "Failed to attach avatar: #{e.message}"
        attach_default_avatar(user)
      end
    else
      attach_default_avatar(user)
    end

    user.password = SecureRandom.alphanumeric(10)
    user.save!
  end

  # リモートURLからアバターを添付する
  def attach_avatar_from_url(user, avatar_url)
    uri = URI.parse(avatar_url)
    response = Net::HTTP.get_response(uri)

    raise "Failed to download avatar: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

    # ファイル名をURLから取得し、適切な拡張子を保持する
    filename = File.basename(uri.path)
    Tempfile.open([filename, File.extname(filename)], binmode: true) do |file|
      file.write(response.body)
      file.rewind
      user.avatar.attach(io: file, filename:)
      file.close # ここでファイルを閉じる
    end
  end

  # デフォルトアバターの添付
  def attach_default_avatar(user)
    default_avatar_path = asset_path('sample.jpg')
    user.avatar.attach(io: File.open(default_avatar_path), filename: 'default_avatar.jpg')
  end

  # アセットパスを取得する
  def asset_path(asset_name)
    if Rails.env.development?
      Rails.application.assets.find_asset(asset_name).filename
    else
      Rails.public_path.join(Rails.application.assets_manifest.files[asset_name]['path']).to_s
    end
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

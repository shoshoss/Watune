class ProfilesController < ApplicationController
  skip_before_action :require_login, only: %i[show]
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show]
  before_action :set_posts, only: %i[show], if: -> { @user.present? }
  before_action :authorize_view!, only: %i[show]

  # プロフィール表示アクション
  def show
    @notifications = current_user&.received_notifications&.unread
    # URLパラメータのカテゴリーが存在しない場合、クッキーからカテゴリーを取得
    category = params[:category] || cookies[get_cookie_key('selected_profile_category')] || default_category
    # 選択されたカテゴリーをクッキーに保存
    cookies[get_cookie_key('selected_profile_category')] = { value: category, expires: 1.year.from_now } if params[:category]

    if @user.nil?
      redirect_to root_path, alert: 'ユーザーが見つかりません。'
      return
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # プロフィール編集アクション
  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # プロフィール更新アクション
  def update
    display_name_param = user_params[:display_name]
    if @user.update(user_params) && display_name_param.blank?
      @user.update(display_name: "ウェーチュン#{@user.id}")
      flash[:notice] = t('defaults.flash_message.updated_with_default_name', item: 'プロフィール')
    elsif @user.update(user_params)
      flash[:notice] = t('defaults.flash_message.updated', item: 'プロフィール')
      redirect_to profile_show_path(username_slug: @user.username_slug)
    else
      flash.now[:alert] = t('defaults.flash_message.update_failed', item: 'プロフィール')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # ユーザーを設定
  def set_user
    @user = User.find_by(username_slug: params[:username_slug])
  end

  # 現在のユーザーを設定
  def set_current_user
    @user = current_user
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # 投稿をフィルタリング
  def filtered_posts(category)
    base_scope = @user.posts
    scopes = {
      'all_my_posts' => base_scope,
      'only_me' => base_scope.where(privacy: 'only_me'),
      'my_posts_following' => Post.my_posts_following(@user, base_scope),
      'my_posts_open' => base_scope.where(privacy: 'open'),
      'posts_to_you' => Post.posts_to_you(@user),
      'bookmarked' => @user.bookmarked_posts.order('bookmarks.created_at DESC'),
      'liked' => @user.liked_posts.order('likes.created_at DESC'),
      'shared_with_you' => Post.shared_with_you(current_user, @user)
    }

    scopes[category] || Post.none
    # パフォーマンス向上のために最後にソートを適用
    posts.order(created_at: :desc)
  end

  # フィルタリングされた投稿を取得
  def set_posts
    category = params[:category] || cookies[get_cookie_key('selected_profile_category')] || default_category
    @pagy, @posts = pagy_countless(
      filtered_posts(category).includes(:user, :category, post_users: :user, audio_attachment: :blob), items: 5
    )
  end

  # プロフィール表示の許可を確認
  def authorize_view!
    category = params[:category] || cookies[get_cookie_key('selected_profile_category')] || default_category
    return if category_accessible?(category)

    redirect_to profile_show_path(username_slug: @user.username_slug, category: 'my_posts_open'), alert: 'この投稿は非公開です。'
  end

  # 特定のカテゴリーへのアクセスを許可するかどうかを確認
  def category_accessible?(category)
    case category
    when 'only_me'
      current_user == @user
    when 'selected_users'
      @user.following?(current_user)
    else
      true
    end
  end

  # デフォルトのカテゴリーを設定
  def default_category
    current_user == @user ? 'all_my_posts' : 'my_posts_open'
  end

  # クッキーキーを生成
  def get_cookie_key(key)
    "#{@user.username_slug}_#{key}"
  end
end

class ProfilesController < ApplicationController
  skip_before_action :require_login, only: %i[show]
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show]
  before_action :set_posts, only: %i[show], if: -> { @user.present? }
  before_action :authorize_view!, only: %i[show]

  # プロフィール表示アクション
  def show
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
    user_posts_scope = @user.posts
    base_scope = Post.all

    scopes = {
      'all_my_posts' => user_posts_scope,
      'only_me' => user_posts_scope.where(privacy: 'only_me'),
      'my_posts_following' => Post.my_posts_following(@user, user_posts_scope),
      'my_posts_open' => user_posts_scope.where(privacy: 'open'),
      'posts_to_you' => Post.posts_to_you(@user),
      'bookmarked' => base_scope.joins(:bookmarks).where(bookmarks: { user_id: @user.id }).order('bookmarks.created_at DESC'),
      'liked' => base_scope.joins(:likes).where(likes: { user_id: @user.id }).order('likes.created_at DESC'),
      'shared_with_you' => Post.shared_with_you(current_user, @user)
    }

    posts = scopes[category] || Post.none
    posts.order(created_at: :desc)
  end

  # フィルタリングされた投稿を取得
  def set_posts
    category = params[:category] || default_category

    # まず、関連データをロードしてから5件の投稿を取得
    @pagy, @posts = pagy_countless(filtered_posts(category)
                                    .includes(:user,
                                              { post_users: :user },
                                              { audio_attachment: :blob },
                                              :bookmarks,
                                              :likes,
                                              { reposts: :user }),
                                   items: 5)
  end

  # プロフィール表示の許可を確認
  def authorize_view!
    category = params[:category] || default_category
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
end

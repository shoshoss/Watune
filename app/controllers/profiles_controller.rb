class ProfilesController < ApplicationController
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show]
  before_action :set_posts, only: %i[show]

  # プロフィール表示アクション
  def show
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
    return unless @user.update(user_params)

    flash.now[:notice] = t('defaults.flash_message.updated', item: Profile.model_name.human)
  end

  private

  # ユーザーを設定
  def set_user
    @user = User.find_by(username_slug: params[:username_slug])
  end

  def set_current_user
    @user = current_user
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # 初期カテゴリを決定
  def determine_initial_category
    current_user == @user ? 'all_my_posts' : 'my_posts_open'
  end

  # 投稿をフィルタリング
  def filtered_posts
    category = params[:category] || determine_initial_category

    scopes = {
      'all_my_posts' => @user.posts,
      'only_me' => @user.posts.only_me,
      'my_posts_open' => @user.posts.open,
      'all_likes_chance' => Post.with_likes_count_all(@user),
      'my_likes_chance' => Post.not_liked_by_user(@user),
      'public_likes_chance' => Post.public_likes_chance(@user),
      'bookmarked' => @user.bookmarked_posts,
      'liked' => @user.liked_posts.visible_to(@user)
    }

    scopes[category] || Post.none
  end

  # フィルタリングされた投稿を取得
  def set_posts
    @pagy, @posts = pagy_countless(filtered_posts.includes(:user).order(created_at: :desc), items: 10)
  end
end

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
  def edit; end

  # プロフィール更新アクション
  def update
    attach_avatar if avatar_params_present?

    if @user.update(user_params)
      set_posts
      flash[:notice] = t('defaults.flash_message.updated', item: Profile.model_name.human)
      respond_to do |format|
        format.html { redirect_to profile_show_path(@user.username_slug), status: :see_other }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  private

  # ユーザーを設定
  def set_user
    @user = User.find_by(username_slug: params[:username_slug])
  end

  def set_current_user
    @user = current_user
  end

  # 投稿をフィルタリングして設定
  def set_posts
    @pagy, @posts = pagy_countless(filtered_posts, items: 10)
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # アバターパラメータの存在チェック
  def avatar_params_present?
    params[:user][:avatar].present?
  end

  # アバターの添付処理
  def attach_avatar
    @user.avatar.attach(params[:user][:avatar]) if @user.avatar.blank?
  end

  # フィルタリングされた投稿を取得
  def filtered_posts
    return Post.none if @user.nil?

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

    scope = scopes[params[:category] || 'all_my_posts'] || Post.none
    scope.includes(:user).order(created_at: :desc)
  end
end

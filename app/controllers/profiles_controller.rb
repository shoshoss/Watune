class ProfilesController < ApplicationController
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show modal]
  before_action :set_posts, only: %i[show], if: -> { @user.present? }

  # プロフィール表示アクション
  def show
    @show_reply_line = false
    return unless @user.nil?

    redirect_to root_path, alert: 'ユーザーが見つかりません。'
    nil
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

    if @user.display_name.blank?
      @user.update(display_name: "ウェーブ登録#{@user.id}")
      flash[:notice] = t('defaults.flash_message.updated_with_default_name', item: 'プロフィール')
      return
    end
    flash.now[:notice] = t('defaults.flash_message.updated', item: 'プロフィール')
  end

  # プロフィールモーダル表示アクション
  def modal
    if @user.nil?
      render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash_message',
                                                         locals: { message: 'ユーザーが見つかりません。' })
      return
    end

    respond_to do |format|
      format.html { render partial: 'profiles/profile_modal', locals: { user: @user } }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('profile_modal', partial: 'profiles/profile_modal',
                                                                   locals: { user: @user })
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

class ProfilesController < ApplicationController
  skip_before_action :require_login, only: %i[show modal]
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show modal]
  before_action :set_posts, only: %i[show], if: -> { @user.present? }

  # プロフィール表示アクション
  def show
    @notifications = current_user&.received_notifications&.unread

    # URLパラメータのカテゴリーが存在しない場合、クッキーからカテゴリーを取得
    category = params[:category] || cookies[:selected_profile_category] || 'my_posts_open'
    # 選択されたカテゴリーをクッキーに保存
    cookies[:selected_profile_category] = { value: category, expires: 1.year.from_now } if params[:category]

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
    else
      flash.now[:alert] = t('defaults.flash_message.update_failed', item: 'プロフィール')
    end
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
    @user = User.find_by(username_slug: params[:username_slug] || current_user.username_slug)
  end

  def set_current_user
    @user = current_user
  end

  # 許可されたパラメータを設定
  def user_params
    params.require(:user).permit(:display_name, :email, :avatar, :username_slug, :self_introduction)
  end

  # 投稿をフィルタリング
  def filtered_posts(category)
    scopes = {
      'all_my_posts' => @user.posts.order(created_at: :desc),
      'only_me' => @user.posts.only_me.order(created_at: :desc),
      'my_posts_following' => Post.my_posts_following(@user),
      'my_posts_open' => @user.posts.my_posts_open.order(created_at: :desc),
      'posts_to_you' => Post.posts_to_you(@user),
      'bookmarked' => @user.bookmarked_posts.order('bookmarks.created_at DESC'),
      'liked' => @user.liked_posts.order('likes.created_at DESC'),
      'shared_with_you' => Post.shared_with_you(current_user, @user)
    }

    scopes[category] || Post.none
  end

  # フィルタリングされた投稿を取得
  # N+1クエリ問題を回避するために関連データを一緒にロード
  def set_posts
    category = params[:category] || cookies[:selected_profile_category] || 'my_posts_open'
    @pagy, @posts = pagy_countless(filtered_posts(category).includes(:user, :category, post_users: :user, audio_attachment: :blob),
                                   items: 5)
  end
end

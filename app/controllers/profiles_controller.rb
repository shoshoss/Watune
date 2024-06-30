class ProfilesController < ApplicationController
  skip_before_action :require_login, only: %i[show modal]
  before_action :set_current_user, only: %i[edit update]
  before_action :set_user, only: %i[show modal]
  before_action :set_posts, only: %i[show], if: -> { @user.present? }

  # プロフィール表示アクション
  def show
    @notifications = current_user&.received_notifications&.unread
    @initial_category = current_user == @user ? 'all_my_posts' : 'my_posts_open'
    
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

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to profile_show_path(@user.username_slug) }
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
      'all_my_posts' => @user.posts.order(created_at: :desc),
      'only_me' => @user.posts.only_me.order(created_at: :desc),
      'my_posts_open' => @user.posts.my_posts_open.order(created_at: :desc),
      'all_likes_chance' => Post.with_likes_count_all(@user),
      'my_likes_chance' => Post.not_liked_by_user(@user),
      'public_likes_chance' => Post.public_likes_chance(@user),
      'bookmarked' => @user.bookmarked_posts.order('bookmarks.created_at DESC'),
      'liked' => @user.liked_posts.order('likes.created_at DESC'),
      'posts_to_you' => Post.posts_to_you(@user),
      'my_posts_following' => Post.my_posts_following(@user),
      'community_posts' => Post.joins(:post_users)
                               .where(post_users: { user: @user, role: 'community_recipient' })
                               .order(created_at: :desc),
      'shared_with_you' => Post.shared_with_you(current_user, @user)
    }

    scopes[category] || Post.none
  end

  # フィルタリングされた投稿を取得
  # N+1クエリ問題を回避するために関連データを一緒にロード
  def set_posts
    @pagy, @posts = pagy_countless(filtered_posts.includes(:user, :reposts, :replies, :likes, :bookmarks, post_users: :user),
                                   items: 10)
  end
end

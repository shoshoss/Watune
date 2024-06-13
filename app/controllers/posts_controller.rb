class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new edit create update]

  def index
    @show_reply_line = false
    @pagy, @posts = pagy_countless(fetch_posts, items: 10)
  end

  def show
    unless @post.visible_to?(current_user)
      redirect_to root_path, alert: 'この投稿を見る権限がありません。'
      return
    end
    @show_reply_line = true
    @notifications = current_user.received_notifications.unread
    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user).order(created_at: :asc), items: 15)
    @parent_posts = @post.ancestors
  end

  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def edit; end

  def create
    @post = current_user.posts.build(post_params.except(:recipient_ids))
    if @post.save
      create_post_users(@post) if params[:post][:recipient_ids].present?
      notify_async(@post, 'direct') if @post.privacy == 'selected_users'

      flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params.except(:recipient_ids))
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Post.model_name.human, default: '投稿の更新に失敗しました。')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    flash.now[:notice] = t('defaults.flash_message.deleted', item: Post.model_name.human, default: '投稿が削除されました。')
    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@post)),
          turbo_stream.update('flash', partial: 'shared/flash_message', locals: { flash: })
        ]
      end
    end
  end

  private

  # 特定の投稿をセットする
  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'この投稿は存在しません。'
  end

  # ログインユーザーの投稿をセットする
  def set_current_user_post
    @post = current_user.posts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'この投稿は存在しません。'
  end

  # 投稿のパラメータを許可する
  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy, :post_reply_id, recipient_ids: [])
  end

  # 投稿に関連するユーザーを作成する
  def create_post_users(post)
    params[:post][:recipient_ids].each do |recipient_id|
      post.post_users.create(user_id: recipient_id, role: 'direct_recipient')
    end
  end

  # 非同期通知を実行する
  def notify_async(post, notification_type)
    NotificationJob.perform_later(notification_type, post.id)
  end

  # フォローしているユーザーを投稿数でソートする
  def set_followings_by_post_count
    @sorted_followings = current_user.following_ordered_by_sent_posts
  end

  # 投稿一覧を取得するメソッド
  def fetch_posts
    Post.left_joins(:reposts)
        .includes(:user, :replies, :reposts)
        .order('COALESCE(reposts.created_at, posts.created_at) DESC')
        .distinct
  end
end

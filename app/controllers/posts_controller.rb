class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  skip_before_action :require_login, only: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new edit create update]
  before_action :authorize_view!, only: [:show]

  # 投稿一覧を表示するアクション
  def index
    @show_reply_line = false
    # 無限スクロールのための投稿データを取得
    @pagy, @posts = pagy_countless(fetch_posts, items: 10)
  end

  # 投稿詳細を表示するアクション
  def show
    @show_reply_line = true
    # 現在のユーザーの未読通知を取得
    @notifications = current_user&.received_notifications&.unread
    @reply = Post.new
    # 返信データを取得し、ページネーションを設定
    @pagy, @replies = pagy_countless(@post.replies.includes(:user).order(created_at: :asc), items: 15)
    # 親投稿を取得
    @parent_posts = @post.ancestors
  end

  # 新しい投稿フォームを表示するアクション
  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  # 投稿を編集するフォームを表示するアクション
  def edit; end

  # 新しい投稿を作成するアクション
  def create
    @post = current_user.posts.build(post_params.except(:recipient_ids))
    if @post.save
      create_post_users(@post) if post_params[:recipient_ids].present?
      notify_async(@post, 'direct') if @post.privacy == 'selected_users'
      expire_cache_for(@post) # キャッシュの削除
      flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
      render :new, status: :unprocessable_entity
    end
  end

  # 投稿を更新するアクション
  def update
    if @post.update(post_params.except(:recipient_ids))
      create_post_users(@post) if post_params[:recipient_ids].present?
      expire_cache_for(@post) # キャッシュの削除
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Post.model_name.human, default: '投稿の更新に失敗しました。')
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿を削除するアクション
  def destroy
    @post.destroy!
    expire_cache_for(@post) # キャッシュの削除
    flash[:notice] = t('defaults.flash_message.deleted', item: Post.model_name.human, default: '投稿が削除されました。')
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
    @post = Rails.cache.fetch("posts/show/#{params[:id]}", expires_in: 12.hours) do
      Post.find(params[:id])
    end
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
    recipient_ids = post_params[:recipient_ids]
    return unless recipient_ids.present?

    recipients = recipient_ids.map do |recipient_id|
      { post_id: post.id, user_id: recipient_id, role: 'direct_recipient', created_at: Time.current, updated_at: Time.current }
    end

    PostUser.insert_all(recipients)
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
    Rails.cache.fetch("posts/index", expires_in: 12.hours) do
      latest_reposts = Repost.select('DISTINCT ON (post_id) *')
                             .order('post_id, created_at DESC')

      Post.open
          .select('posts.*, COALESCE(latest_reposts.created_at, posts.created_at) AS reposted_at')
          .joins("LEFT JOIN (#{latest_reposts.to_sql}) AS latest_reposts ON latest_reposts.post_id = posts.id")
          .includes(:user, :reposts, :replies, :likes) # 関連データを一度にロードする
          .order(Arel.sql('reposted_at DESC'))
    end
  end

  # 投稿の表示権限を確認する
  def authorize_view!
    return if @post.visible_to?(current_user)

    redirect_to root_path, alert: 'この投稿を見る権限がありません。'
  end

  # キャッシュを削除するメソッド
  def expire_cache_for(post)
    ActionController::Base.new.expire_fragment("post/#{post.id}")
  end
end

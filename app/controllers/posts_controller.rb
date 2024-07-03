class PostsController < ApplicationController
  include PostsHelper
  include ActionView::RecordIdentifier

  skip_before_action :require_login, only: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new_test create_test new edit create update]
  before_action :authorize_view!, only: [:show]

  # テスト用の音声投稿フォームを表示するアクション
  def new_test
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def index_test
    @show_reply_line = false
    # 無限スクロールのための投稿データを取得
    @pagy, @posts = pagy_countless(Post.order(created_at: :desc), items: 20)
  end

  def create_test
    @post = current_user.posts.build(post_params.except(:recipient_ids))

    if @post.save
      # オーディオファイルにキャッシュヘッダーを設定
      if @post.audio.attached?
        set_cache_headers(@post.audio.blob)
      end

      respond_to do |format|
        format.html { redirect_to user_post_path(current_user.username_slug, @post), notice: '投稿が作成されました。' }
        format.json { render json: @post, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new_test, alert: '投稿の作成に失敗しました。' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

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
    @pagy, @replies = pagy_countless(@post.replies.includes(:user, :replies, :likes, :bookmarks).order(created_at: :asc),
                                     items: 15)
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
    @post = current_user.posts.build(post_params.except(:recipient_ids, :custom_category))
    if post_params[:fixed_category] == 'other'
      custom_category = Category.find_or_create_by(category_name: post_params[:custom_category])
      @post.category = custom_category
    end
    if @post.save
      # オーディオファイルにキャッシュヘッダーを設定
      if @post.audio.attached?
        set_cache_headers(@post.audio)
      end

      if post_params[:recipient_ids].present?
        PostCreationJob.perform_later(@post.id, post_params[:recipient_ids],
                                      @post.privacy)
      end
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
      if post_params[:fixed_category] == 'other'
        custom_category = Category.find_or_create_by(category_name: post_params[:custom_category])
        @post.update(category: custom_category)
      end

      # オーディオファイルにキャッシュヘッダーを設定
      if @post.audio.attached?
        set_cache_headers(@post.audio)
      end

      if post_params[:recipient_ids].present? || @post.privacy == 'selected_users'
        PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy)
      end
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
end

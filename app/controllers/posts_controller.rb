class PostsController < ApplicationController
  include PostsAllHelper
  include ActionView::RecordIdentifier

  skip_before_action :require_login, only: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_followings_by_post_count, only: %i[new edit create update]
  before_action :authorize_view!, only: [:show]

  # 投稿一覧を表示するアクション
  def index
    @current_category = cookies[:selected_post_category] || 'recommended'

    pagy, posts = pagy_countless(
      fetch_posts_by_fixed_category(@current_category).includes([:user, :category, { audio_attachment: :blob }, :bookmarks,
                                                                 :likes, { reposts: :user }]),
      items: 3,
      overflow: :empty_page
    )
    @posts_by_category = { @current_category => posts }
    @pagys = { @current_category => pagy }

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: render_to_string(
            partial: 'posts/tab_posts_list',
            locals: {
              posts:,
              tab_category: @current_category,
              pagy: @pagys[@current_category],
              notifications: @notifications
            },
            formats: [:html]
          )
        }
      end
    end
  end

  # 投稿詳細を表示するアクション
  def show
    @show_reply_line = true
    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user, :replies, :likes, :bookmarks).order(created_at: :asc),
                                     items: 15)
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
    assign_custom_category if post_params[:custom_category].present?

    if @post.save
      handle_successful_create
    else
      handle_failed_create
    end
  end

  # 投稿を更新するアクション
  def update
    if @post.update(post_params.except(:recipient_ids))
      assign_custom_category if post_params[:custom_category].present?
      cache_headers(@post.audio) if @post.audio.attached?

      PostCreationJob.perform_later(@post.id, post_params[:recipient_ids], @post.privacy) if post_params[:recipient_ids].present?
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
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

  private

  # 成功した投稿作成の処理
  def handle_successful_create
    flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
    recipient_ids = post_params[:recipient_ids] || []
    PostCreationJob.perform_later(@post.id, recipient_ids, @post.privacy)
    redirect_based_on_privacy
  end

  # 失敗した投稿作成の処理
  def handle_failed_create
    flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
    render :new, status: :unprocessable_entity
  end
end

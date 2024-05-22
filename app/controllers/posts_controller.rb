class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_post, only: %i[show]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :set_send_to_user, only: [:show]

  def index
    # 投稿の一覧を取得し、ページネーションを設定
    @pagy, @posts = pagy_countless(Post.open.includes(:user).order(created_at: :desc), items: 10)
  end

  def show
    # 投稿を取得し、返信のページネーションを設定
    begin
      @post = Post.includes(:user).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'この投稿は削除されました。'
      return
    end

    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user).order(created_at: :desc), items: 10)
  end

  def new
    # 新規投稿フォームの設定
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def edit; end

  def create
    # 新規投稿の作成
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human, default: '投稿が作成されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] =
        t('defaults.flash_message.not_created', item: Post.model_name.human, default: '投稿の作成に失敗しました。')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human, default: '投稿が更新されました。')
      redirect_to user_post_path(current_user.username_slug, @post)
    else
      flash.now[:danger] =
        t('defaults.flash_message.not_updated', item: Post.model_name.human, default: '投稿の更新に失敗しました。')
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

  def set_post
    @post = Post.find_by(id: params[:id])
    if @post.nil?
      redirect_to root_path, alert: 'この投稿は削除されました。'
    end
  end

  def set_current_user_post
    @post = current_user.posts.find(params[:id])
  end

  def set_send_to_user
    if @post.parent_post.present?
      @send_to_user = @post.parent_post.user
    else
      @send_to_user = @post.user
    end
  end

  def authorize_show
    # 投稿の表示権限を確認
    return if @post.user == current_user || @post.privacy == 'open'

    redirect_to root_path, alert: 'この投稿は表示できません。'
  end

  def post_params
    # 投稿パラメータの設定
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy, :post_reply_id)
  end
end

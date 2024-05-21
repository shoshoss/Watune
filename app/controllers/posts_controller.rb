class PostsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_post, only: %i[show]
  before_action :set_current_user_post, only: %i[edit update destroy]
  before_action :authorize_show, only: %i[show]

  def index
    @pagy, @posts = pagy_countless(Post.open.includes(:user).order(created_at: :desc), items: 10)
  end

  def show
    @reply = Post.new
    @pagy, @replies = pagy_countless(@post.replies.includes(:user).order(created_at: :desc), items: 10)
    params[:privacy] ||= @post.privacy
  end

  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def privacy_settings
    @post = Post.new(privacy: params[:privacy])
    Rails.logger.debug { "Privacy parameter received: #{params[:privacy]}" }
    respond_to do |format|
      format.html { render partial: 'posts/privacy_settings', locals: { post: @post } }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('privacy-settings', partial: 'posts/privacy_settings',
                                                                      locals: { post: @post })
      end
    end
  end

  def edit; end

  def create
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
    @post = Post.find(params[:id])
  end

  def set_current_user_post
    @post = current_user.posts.find(params[:id])
  end

  def authorize_show
    return if @post.user == current_user || @post.privacy == 'open'

    redirect_to root_path, alert: 'この投稿は表示できません。'
  end

  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy, :post_reply_id)
  end
end

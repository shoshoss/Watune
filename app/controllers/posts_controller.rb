class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  def index
    @pagy, @posts = pagy_countless(Post.open.includes(:user).order(created_at: :desc), items: 10)
    # @posts = Post.includes(:user).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show; end

  def new
    @post = Post.new
    params[:privacy] ||= @post.privacy
  end

  def privacy_settings
    @post = Post.new(privacy: params[:privacy])
    Rails.logger.debug "Privacy parameter received: #{params[:privacy]}"
    respond_to do |format|
      format.html { render partial: 'posts/privacy_settings', locals: { post: @post } }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("privacy-settings", partial: "posts/privacy_settings", locals: { post: @post }) }
    end
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:notice] = t('defaults.flash_message.created', item: Post.model_name.human)
    else
      flash.now[:danger] = t('defaults.flash_message.not_created', item: Post.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = t('defaults.flash_message.updated', item: Post.model_name.human)
    else
      flash.now[:danger] = t('defaults.flash_message.not_updated', item: Post.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    flash.now[:notice] = t('defaults.flash_message.deleted', item: Post.model_name.human)

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(post)),
          turbo_stream.update('flash', partial: 'shared/flash_message', locals: { flash: })
        ]
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy)
  end
end

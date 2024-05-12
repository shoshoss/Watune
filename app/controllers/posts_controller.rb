class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  def index
    @pagy, @posts = pagy_countless(Post.includes(:user).order(created_at: :desc), items: 10)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
    # @posts = Post.includes(:user).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show; end

  def new
    @post = Post.new
  end

  def edit
    @post = current_user.posts.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.turbo_stream # 特にTurbo Streamsを使用する場合
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
    respond_to do |format|
      format.html { redirect_to posts_path, success: t('defaults.flash_message.deleted', item: Post.model_name.human), status: :see_other }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(dom_id(post))
      end
    end
  end
  

  private

  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy)
  end
end

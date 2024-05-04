class PostsController < ApplicationController
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

  def edit; end

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
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy)
  end
end

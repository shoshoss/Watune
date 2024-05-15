class LikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @like = current_user.likes.build(post: @post)

    if @like.save
      respond_to do |format|
        format.html { redirect_to @post, notice: 'You liked this post.' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to @post, alert: 'Unable to like this post.' }
        format.turbo_stream
      end
    end
  end

  def destroy
    @like = current_user.likes.find(params[:id])
    @post = @like.post
    @like.destroy

    respond_to do |format|
      format.html { redirect_to @post, notice: 'You unliked this post.' }
      format.turbo_stream
    end
  end
end

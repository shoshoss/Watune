class LikesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @like = current_user.likes.build(post: @post)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @like = current_user.likes.find(params[:id])
    @post = @like.post
    @like.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end
end

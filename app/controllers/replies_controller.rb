class RepliesController < ApplicationController
  before_action :set_post

  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      flash[:notice] = '返信しました。'
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_post_path(@post.user.username_slug, @post), notice: '返信が作成されました。' }
      end
    else
      flash.now[:danger] = '返信できませんでした。'
      respond_to do |format|
        format.turbo_stream
        format.html { render 'posts/show', status: :unprocessable_entity }
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def reply_params
    params.require(:post).permit(:body)
  end
end

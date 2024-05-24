class RepliesController < ApplicationController
  before_action :set_post
  before_action :set_send_to_user, only: [:create]

  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      flash[:notice] = '返信しました！'
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_post_path(@post.user.username_slug, @post), notice: '返信が作成されました。' }
      end
    else
      flash.now[:danger] = 'お手数をおかけします。返信できませんでした。'
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

  def set_send_to_user
    @send_to_user = @post.parent_post ? @post.parent_post.user : @post.user
  end

  def reply_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy)
  end
end

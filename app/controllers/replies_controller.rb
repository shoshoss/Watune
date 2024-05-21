class RepliesController < ApplicationController
  before_action :set_post

  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_post_path(@post.user.username_slug, @post), notice: '返信が作成されました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_reply", partial: "replies/form", locals: { post: @post, reply: @reply }) }
        format.html do
          flash.now[:danger] = '返信の作成に失敗しました。'
          @pagy, @replies = pagy(@post.replies.order(created_at: :desc), items: 10)
          render 'posts/show', status: :unprocessable_entity
        end
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

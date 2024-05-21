class RepliesController < ApplicationController
  before_action :set_post

  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      flash[:notice] = '返信が作成されました。'
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_post_path(@post.user.username_slug, @post), notice: '返信が作成されました。' }
      end
    else
      flash.now[:danger] = '返信の作成に失敗しました。'
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("error_messages", partial: "shared/error_messages", locals: { object: @reply }),
            turbo_stream.update("flash", partial: "shared/flash_message")
          ]
        end
        format.html do
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

class RepliesController < ApplicationController
  before_action :set_post, only: %i[new_modal create_modal create]

  def new_modal
    @show_reply_line = true
    @reply = Post.new
    @parent_posts = @post.ancestors
  end

  def create_modal
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      notify_async(@reply, 'reply')
      flash[:notice] = '返信しました！'
    else
      flash.now[:danger] = 'お手数をおかけします。返信できませんでした。'
      render :new_modal, status: :unprocessable_entity
    end
  end

  def create
    @reply = @post.replies.build(reply_params)
    @reply.user = current_user
    if @reply.save
      notify_async(@reply, 'reply')
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

  def reply_params
    params.require(:post).permit(:user_id, :body, :audio, :duration, :privacy).merge(post_reply_id: @post.id)
  end

  # 非同期通知を実行する
  def notify_async(post, notification_type)
    NotificationJob.perform_later(notification_type, post.id)
  end
end

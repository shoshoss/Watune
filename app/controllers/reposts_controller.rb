class RepostsController < ApplicationController
  before_action :set_post

  def create
    if current_user.repost?(@post)
      redirect_to root_path, alert: '既にリポスト済みです'
    else
      @repost = current_user.repost(@post)
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy
    @repost = current_user.un_repost(@post)
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

class RepostsController < ApplicationController
  before_action :set_post

  def create
    if Repost.exists?(user: current_user, post: @post)
      redirect_to root_path, alert: '既にリポスト済みです'
    else
      @repost = Repost.create(user: current_user, post: @post, original_post: @post)
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy
    @repost = Repost.find_by(user: current_user, post: @post)
    if @repost
      @repost.destroy
      respond_to do |format|
        format.turbo_stream
      end
    else
      redirect_to root_path, alert: 'リポストが見つかりません'
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

class LikesController < ApplicationController
  before_action :set_post

  def create
    @like = current_user.like(@post)
    update_likes_chance_count

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @like = current_user.unlike(@post)
    update_likes_chance_count

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def update_likes_chance_count
    @likes_chance_count = Post.with_likes_count_all(current_user).count.keys.size
  end
end

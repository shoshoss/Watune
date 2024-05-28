class LikesController < ApplicationController
  before_action :set_post
  before_action :set_likes_chance_count, only: %i[create destroy]

  def create
    @like = current_user.like(@post)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @like = current_user.unlike(@post)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_likes_chance_count
    @likes_chance_count = Post.with_likes_count_all(current_user).count.size
  end
end

class BookmarksController < ApplicationController
  before_action :set_post

  def create
    @bookmark = current_user.bookmark(@post)
    respond_to do |format|
      format.turbo_stream
    end
  end

  def destroy
    @bookmark = current_user.unbookmark(@post)
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

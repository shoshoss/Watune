class PostUsersController < ApplicationController
  before_action :set_post, only: %i[create destroy]

  # 受信者の追加
  def create
    @post_user = @post.post_users.build(post_user_params)
    if @post_user.save
      flash[:notice] = "受信者が追加されました。"
    else
      flash[:alert] = "受信者の追加に失敗しました。"
    end
    redirect_to user_post_path(@post.user.username_slug, @post)
  end

  # 受信者の削除
  def destroy
    @post_user = @post.post_users.find(params[:id])
    @post_user.destroy
    flash[:notice] = "受信者が削除されました。"
    redirect_to user_post_path(@post.user.username_slug, @post)
  end

  private

  # 対象の投稿を設定
  def set_post
    @post = Post.find(params[:post_id])
  end

  # 許可されたパラメータを設定
  def post_user_params
    params.require(:post_user).permit(:user_id, :role)
  end
end

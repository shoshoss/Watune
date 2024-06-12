class RepostsController < ApplicationController
  before_action :set_post

  def create
    if params[:body].present?
      # 引用リポストの作成
      @repost = Repost.new(user: current_user, post: @post, original_post: @post, body: params[:body])
    else
      # 通常のリポストの作成
      if Repost.exists?(user: current_user, post: @post)
        redirect_to root_path, alert: '既にリポスト済みです'
        return
      end
      @repost = Repost.new(user: current_user, post: @post, original_post: @post)
    end

    if @repost.save
      redirect_to root_path, notice: 'リポストしました'
    else
      redirect_to root_path, alert: 'リポストに失敗しました'
    end
  end

  def destroy
    @repost = Repost.find_by(user: current_user, post: @post)
    if @repost
      @repost.destroy
      redirect_to root_path, notice: 'リポストを取り消しました'
    else
      redirect_to root_path, alert: 'リポストが見つかりません'
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

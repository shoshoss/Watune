class FriendshipsController < ApplicationController
  before_action :set_user, only: %i[index create destroy]
  before_action :ensure_correct_user, only: %i[index]

  # フォローリストまたはフォロワーリストの表示
  def index
    @category = params[:category] || 'following'
    if @category == 'followers'
      @pagy, @users = pagy_countless(@user.followers, items: 15)
    else
      @pagy, @users = pagy_countless(@user.followings, items: 15)
    end
    render :index
  end

  # フォローの作成
  def create
    current_user.follow(@user)
    update_unfollowed_users_count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: t('.notice') }
    end
  end

  # フォローの削除
  def destroy
    current_user.unfollow(@user)
    update_unfollowed_users_count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: t('.notice') }
    end
  end

  private

  # ユーザーを設定する
  def set_user
    @user = if action_name == 'index'
              User.find_by(username_slug: params[:username_slug])
            else
              User.find(params[:user_id])
            end
    return if @user

    redirect_to root_path, alert: 'ユーザーが見つかりません'
  end

  # ユーザーが正しいか確認する
  def ensure_correct_user
    redirect_to root_path, alert: 'アクセス権がありません' unless current_user == @user
  end

  # フォローしていないユーザー数を更新する
  def update_unfollowed_users_count
    @unfollowed_users_count = User.where.not(id: current_user.following_ids).count
  end
end

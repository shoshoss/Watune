class FriendshipsController < ApplicationController
  before_action :set_user, only: %i[index create destroy]
  before_action :ensure_correct_user, only: %i[index]

  def index
    @category = params[:category] || 'followings'
    @pagy, @users = if @category == 'followers'
                      pagy_countless(@user.followers, items: 15)
                    else
                      pagy_countless(@user.followings, items: 15)
                    end
    render :index
  end

  def create
    current_user.follow(@user)
    update_unfollowed_users_count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: t('.notice') }
    end
  end

  def destroy
    current_user.unfollow(@user)
    update_unfollowed_users_count

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: t('.notice') }
    end
  end

  private

  def set_user
    if action_name == 'index'
      @user = User.find_by(username_slug: params[:username_slug])
    else
      @user = User.find(params[:user_id])
    end
    unless @user
      redirect_to root_path, alert: 'ユーザーが見つかりません'
    end
  end

  def ensure_correct_user
    redirect_to root_path, alert: 'アクセス権がありません' unless current_user == @user
  end

  def update_unfollowed_users_count
    @unfollowed_users_count = User.where.not(id: current_user.following_ids).count
  end
end

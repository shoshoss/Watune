class FriendshipsController < ApplicationController
  before_action :set_user, only: %i[create destroy followings followers]

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user, notice: t('.notice') }
      format.turbo_stream
    end
  end

  def destroy
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, notice: t('.notice') }
      format.turbo_stream
    end
  end

  def followings
    @category = 'followings'
    @pagy, @users = pagy_countless(@user.followings, items: 15)
    render :index
  end

  def followers
    @category = 'followers'
    @pagy, @users = pagy_countless(@user.followers, items: 15)
    render :index
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

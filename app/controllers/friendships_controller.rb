class FriendshipsController < ApplicationController
  before_action :set_user

  def create
    current_user.follow(@user)
    redirect_to user_path(@user), notice: t('.notice')
  end

  def destroy
    current_user.unfollow(@user)
    redirect_to user_path(@user), notice: t('.notice')
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

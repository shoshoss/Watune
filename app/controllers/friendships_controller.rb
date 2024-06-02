class FriendshipsController < ApplicationController
  before_action :set_user

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

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

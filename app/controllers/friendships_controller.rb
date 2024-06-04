class FriendshipsController < ApplicationController
  before_action :set_user, only: %i[create destroy index]

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

  def index
    @category = params[:category] || 'followings'
    @pagy, @users = if @category == 'followers'
                      pagy_countless(@user.followers, items: 15)
                    else
                      pagy_countless(@user.followings, items: 15)
                    end
    render :index
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

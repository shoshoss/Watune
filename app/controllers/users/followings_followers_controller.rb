class Users::FollowingsFollowersController < ApplicationController
  before_action :set_user

  def index
    @category = params[:category] || 'followings'
    @pagy, @users = if @category == 'followers'
                      pagy_countless(@user.followers, items: 15)
                    else
                      pagy_countless(@user.followings, items: 15)
                    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end

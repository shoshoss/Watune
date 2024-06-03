class Users::FollowingsFollowersController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    if params[:category] == 'followers'
      @pagy, @followers = pagy_countless(@user.followers, items: 15)
    else
      @pagy, @followings = pagy_countless(@user.followings, items: 15)
    end
  end
end

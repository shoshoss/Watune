class Users::FollowingsFollowersController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @followings = @user.followings
    @followers = @user.followers
  end
end

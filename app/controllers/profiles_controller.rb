# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path(@user.username_slug), notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username_slug, :email, :password, :password_confirmation)
  end
end

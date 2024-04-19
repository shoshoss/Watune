# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: 'プロファイルが更新されました。'
    else
      flash.now[:error] = 'プロファイルの更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:display_name, :username_slug, :self_introduction)
  end
end

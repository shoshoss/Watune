# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  before_action :set_user, only: %i[edit update]

  def show
    @user = User.find_by(username_slug: params[:username_slug])
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, status: :see_other, notice: 'プロファイルが更新されました。'
    else
      flash.now[:error] = 'プロファイルの更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(current_user.id)
  end

  def user_params
    params.require(:user).permit(:display_name, :username_slug, :self_introduction)
  end
end

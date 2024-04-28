class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create]

  def new_modal
    @user = User.new
  end

  def create_modal
    @user = User.new(user_params)
    if @user.save
      login(user_params[:email], user_params[:password])
      respond_to do |format|
        format.html { redirect_to edit_profile_path, status: :see_other, notice: 'ユーザー登録に成功しました' }
      end
    else
      flash.now[:error] = 'ユーザー登録に失敗しました'
      render :new_modal, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login(user_params[:email], user_params[:password])
      redirect_to edit_profile_path, status: :see_other, notice: 'ユーザー登録に成功しました'
    else
      flash.now[:error] = 'ユーザー登録に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end

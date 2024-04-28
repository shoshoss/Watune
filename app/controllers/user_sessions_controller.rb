class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create]

  def new_modal; end

  def create_modal
    @user = login(params[:email], params[:password])

    return if @user

    respond_to do |format|
      format.html do
        flash.now[:error] = 'ログインに失敗しました'
        render :new_modal, status: :unprocessable_entity
      end
    end
  end

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_to root_path, status: :see_other, notice: 'ログインしました'
    else
      flash.now[:error] = 'ログインに失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end
end

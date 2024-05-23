class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create]

  def new_modal; end

  def create_modal
    @user = login(params[:email], params[:password])

    if @user
      flash[:notice] = t('flash_messages.user_sessions.login_success')
    else
      flash.now[:danger] = t('flash_messages.user_sessions.login_failure')
      render :new_modal, status: :unprocessable_entity
    end
  end

  def new; end

  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_to root_path, status: :see_other, notice: t('flash_messages.user_sessions.login_success')
    else
      flash.now[:danger] = t('flash_messages.user_sessions.login_failure')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other, notice: t('flash_messages.user_sessions.logout')
  end
end

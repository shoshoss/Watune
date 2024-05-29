class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create guest_login]

  def new_modal
    @user = User.new
  end

  def create_modal
    if current_user&.guest?
      @user = current_user
      unless @user.update(user_params.merge(guest: false))
        flash.now[:error] = I18n.t('flash_messages.users.signup_failure')
      end
    else
      @user = User.new(user_params)
      if @user.save
        login(user_params[:email], user_params[:password])
      else
        flash.now[:error] = I18n.t('flash_messages.users.signup_failure')
      end
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def new
    @user = User.new
  end

  def create
    if current_user&.guest?
      @user = current_user
      if @user.update(user_params.merge(guest: false))
        redirect_to edit_profile_path, status: :see_other
      else
        flash.now[:error] = I18n.t('flash_messages.users.signup_failure')
        render :new, status: :unprocessable_entity
      end
    else
      @user = User.new(user_params)
      if @user.save
        login(user_params[:email], user_params[:password])
        redirect_to edit_profile_path, status: :see_other
      else
        flash.now[:error] = I18n.t('flash_messages.users.signup_failure')
        render :new, status: :unprocessable_entity
      end
    end
  end

  def guest_login
    email = generate_unique_guest_email
    @user = User.create!(email:, password: SecureRandom.hex(10), guest: true)
    auto_login(@user)
    set_flash(:before_profile_edit_flash, I18n.t('flash_messages.users.guest_login_success'))
    respond_to do |format|
      format.html { redirect_to edit_profile_path }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error I18n.t('flash_messages.users.guest_login_failure') + ": #{e.message}"
    flash.now[:alert] = I18n.t('flash_messages.users.guest_login_failure')
    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream { render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash_message', locals: { flash: { danger: I18n.t('flash_messages.users.guest_login_failure') } }) }
    end
  end
  
  

  private

  def user_params
    params.require(:user).permit(:email, :password, :display_name, :username_slug, :self_introduction)
  end

  def generate_unique_guest_email
    loop do
      email = "guest_#{SecureRandom.hex(10)}@example.com"
      break email unless User.exists?(email:)
    end
  end
end

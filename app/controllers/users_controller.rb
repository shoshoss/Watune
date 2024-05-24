class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create guest_login]

  def new_modal
    @user = User.new
  end

  def create_modal
    @user = User.new(user_params)
    if @user.save
      if current_user&.guest?
        transfer_guest_data(@user)
        update_username_slug(@user, current_user.username_slug)
      end
      login(user_params[:email], user_params[:password])
    else
      flash.now[:error] = I18n.t('flash_messages.users.registration_failure')
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if current_user&.guest?
        transfer_guest_data(@user)
        update_username_slug(@user, current_user.username_slug)
      end
      login(user_params[:email], user_params[:password])
      redirect_to edit_profile_path, status: :see_other, notice: I18n.t('flash_messages.users.registration_success')
    else
      flash.now[:error] = I18n.t('flash_messages.users.registration_failure')
      render :new, status: :unprocessable_entity
    end
  end

  def guest_login
    @user = User.create!(email: "guest_#{SecureRandom.hex(10)}@example.com", password: SecureRandom.hex(10), guest: true)
    auto_login(@user)
    redirect_to profile_show_path(@user.username_slug), notice: 'お試しログインしました。'
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def transfer_guest_data(user)
    guest_user = current_user
    user.transfer_data_from_guest(guest_user)
  end

  def update_username_slug(user, new_slug)
    user.update(username_slug: new_slug)
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = "ユーザー名の引き継ぎに失敗しました。他のユーザー名を選択してください。"
  end
end

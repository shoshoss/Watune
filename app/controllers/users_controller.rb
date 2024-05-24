class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new_modal create_modal new create guest_login]

  def new_modal
    @user = User.new
  end

  def create_modal
    @user = User.new(user_params)
    if @user.save
      transfer_guest_data_to(@user) if current_user&.guest?
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
    redirect_to posts_path, notice: 'お試しログインしました。'
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def transfer_guest_data_to(user)
    guest_user = current_user
    guest_user.posts.update_all(user_id: user.id)
    guest_user.likes.update_all(user_id: user.id)
    guest_user.bookmarks.update_all(user_id: user.id)
    guest_user.destroy
  end
end

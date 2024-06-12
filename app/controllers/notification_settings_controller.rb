class NotificationSettingsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(notification_settings_params)
      redirect_to edit_notification_settings_path, notice: '通知設定が更新されました。'
    else
      render :edit
    end
  end

  private

  def notification_settings_params
    params.require(:user).permit(:notification_email, :notify_on_reply, :notify_on_direct_message, :notify_on_like,
                                 :notify_on_follow, :notification_frequency, :notification_time)
  end
end

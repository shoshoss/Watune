class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find(user.id)
    @url = edit_password_reset_url(@user.reset_password_token)
    mail(to: user.email, subject: t('defaults.password_reset'))
  end

  def reply_notification(user, reply)
    @user = user
    @reply = reply
    @url = notifications_url
    mail(to: @user.email, subject: '新しい返信があります')
  end

  def direct_notification(user, post)
    @user = user
    @post = post
    @url = notifications_url
    mail(to: @user.email, subject: '新しいダイレクトメッセージがあります')
  end

  private

  def notifications_url
    url_for(controller: 'notifications', action: 'index', only_path: false)
  end
end

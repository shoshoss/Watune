class NotificationsController < ApplicationController
  def index
    @category = params[:category] || 'all'
    if @category == 'friends'
      notifications_scope = current_user.received_notifications.unread.where(action: ['reply', 'post'])
    else
      notifications_scope = current_user.received_notifications.unread
    end
    @pagy, @notifications = pagy_countless(notifications_scope.includes(:sender, :notifiable).order(created_at: :desc), items: 10)

    # 未読通知を既読にする
    notifications_scope.update_all(unread: false)
  end

end

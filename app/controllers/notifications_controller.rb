class NotificationsController < ApplicationController
  def index
    @pagy, @notifications = pagy_countless(current_user.received_notifications.unread.order(created_at: :desc), items: 10)
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @notification = current_user.received_notifications.find(params[:id])
    if @notification.update(unread: false)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@notification),
            turbo_stream.replace('notification_count', partial: 'notifications/notification_count',
                                                       locals: { notifications: current_user.received_notifications.unread })
          ]
        end
        format.html
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('notifications', '')
          ]
        end
      end
    end
  end

  def mark_all_as_read
    @notifications = current_user.received_notifications.unread
    @notifications.each do |notification|
      notification.update(unread: false)
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove('notifications'),
          turbo_stream.replace('notification_count', partial: 'notifications/notification_count',
                                                     locals: { notifications: current_user.received_notifications.unread }),
          turbo_stream.prepend('no_notification', partial: 'notifications/no_notification')
        ]
      end
      format.html
    end
  end
end

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @notifications = pagy(current_user.received_notifications.order(created_at: :desc), items: 20)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append('notifications', partial: 'notifications/notification', collection: @notifications,
                                               as: :notification),
          turbo_stream.replace('notification_count', partial: 'notifications/notification_count',
                                                     locals: { notifications: @notifications })
        ]
      end
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

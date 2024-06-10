class NotificationsController < ApplicationController
  def index
    @category = params[:category] || 'unread'
    notifications_scope = case @category
                          when 'unread'
                            current_user.received_notifications.unread
                          when 'friends'
                            current_user.received_notifications.where(action: %w[reply direct], unread: false)
                          when 'likes_and_follows'
                            current_user.received_notifications.where(action: %w[like follow], unread: false)
                          else
                            current_user.received_notifications
                          end

    @pagy, @notifications = pagy_countless(notifications_scope.includes(:sender, :notifiable).order(created_at: :desc),
                                           items: 10)

    # 未読通知を既読にする
    # バリデーション不要な一括更新のため、update_allを使用
    # rubocop:disable Rails/SkipsModelValidations
    notifications_scope.update_all(unread: false) if @category == 'unread'
    # rubocop:enable Rails/SkipsModelValidations
  end
end

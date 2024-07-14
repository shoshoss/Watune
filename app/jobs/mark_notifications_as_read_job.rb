class MarkNotificationsAsReadJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    # バリデーション不要な一括更新のため、update_allを使用
    # rubocop:disable Rails/SkipsModelValidations
    user.received_notifications.update_all(unread: false)
    # rubocop:enable Rails/SkipsModelValidations
  end
end

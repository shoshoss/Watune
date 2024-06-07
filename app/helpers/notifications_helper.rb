module NotificationsHelper
  def generate_notification_message(notification)
    case notification.action
    when 'like'
      # いいねの通知
      "#{notification.sender.display_name}さんがあなたの投稿に応援しました。"
    when 'reply'
      # 返信の通知
      "#{notification.sender.display_name}さんがあなたへ返信しました。"
    when 'follow'
      # フォローの通知
      "#{notification.sender.display_name}さんがあなたをフォローしました。"
    when 'post'
      # 投稿の通知
      "#{notification.sender.display_name}さんがあなたへ投稿しました。"
    else
      # デフォルトの通知メッセージ
      '新しい通知があります。'
    end
  end
end

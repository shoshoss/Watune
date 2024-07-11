// app/javascript/controllers/notification_controller.js

import { Controller } from "@hotwired/stimulus"; // Stimulusコントローラをインポート

export default class extends Controller {
  static targets = ["notificationCount"]; // notificationCountターゲットを定義
  static values = { url: String }; // url値を定義

  connect() {
    this.checkNotifications(); // 通知をチェック
    this.interval = setInterval(this.checkNotifications.bind(this), 30000); // 30秒間隔で通知をチェック
  }

  disconnect() {
    clearInterval(this.interval); // コントローラが切断されたときにインターバルをクリア
  }

  checkNotifications() {
    fetch(this.urlValue) // URLから通知データを取得
      .then((response) => response.json())
      .then((data) => {
        this.handleNotification(data); // 取得したデータを処理
      })
      .catch((error) => console.error("Error fetching notifications:", error)); // エラーハンドリング
  }

  handleNotification(data) {
    // 取得したデータの処理をここに記述
    // 例: 未読通知数の表示更新など
    if (this.hasNotificationCountTarget && data.unread_count !== undefined) {
      if (data.unread_count > 0) {
        this.notificationCountTarget.textContent = data.unread_count; // 未読通知数を更新
        this.notificationCountTarget.style.display = "block"; // カウントを表示
      } else {
        this.notificationCountTarget.style.display = "none"; // カウントを非表示
      }
    }
  }
}

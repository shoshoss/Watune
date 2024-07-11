// app/javascript/controllers/notification_controller.js

import { Controller } from "stimulus";

export default class extends Controller {
  static values = { url: String };

  connect() {
    this.checkNotifications();
    this.interval = setInterval(this.checkNotifications.bind(this), 30000); // 30秒間隔で通知をチェック
  }

  disconnect() {
    clearInterval(this.interval); // コントローラが切断されたときにインターバルをクリア
  }

  checkNotifications() {
    fetch(this.urlValue)
      .then((response) => response.json())
      .then((data) => {
        this.handleNotification(data);
      })
      .catch((error) => console.error("Error fetching notifications:", error));
  }

  handleNotification(data) {
    // 取得したデータの処理をここに記述
    // 例: 未読通知数の表示更新など
    const notificationElement = document.querySelector("#notification-count");
    if (notificationElement && data.count !== undefined) {
      notificationElement.textContent = data.count;
    }
  }
}

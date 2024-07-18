import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // イベントリスナーを追加
    this.element.addEventListener("click", this.specialLinkHandler.bind(this));
  }

  specialLinkHandler(event) {
    const id = event.target.closest("a").id;
    if (
      [
        "header-notifications-link",
        "sidebar-notifications-link",
        "bottom-navbar-notifications-link",
      ].includes(id)
    ) {
      this.hideUnreadCountAfterDelay();
    }
  }

  hideUnreadCountAfterDelay() {
    const notificationLinks = [
      "#bottom-navbar-notifications-link .absolute",
      "#header-notifications-link .absolute",
      "#sidebar-notifications-link .absolute",
    ];

    setTimeout(() => {
      notificationLinks.forEach((selector) => {
        const unreadCountElement = document.querySelector(selector);
        if (unreadCountElement) {
          unreadCountElement.style.display = "none";
        }
      });
    }, 5000); // 5秒後に実行
  }
}

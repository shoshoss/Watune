// app/javascript/controllers/bottom_history_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.updateActiveLink(window.location.pathname);
    window.addEventListener("popstate", this.handlePopState.bind(this));
  }

  navigate(event) {
    event.preventDefault();
    const url = new URL(event.currentTarget.href);

    // Turboフレームでの遷移
    document.querySelector("#main-content").src = url.pathname;

    // URLを変更し、履歴に追加
    history.pushState({ url: url.pathname }, "", url.pathname);

    // アクティブなリンクを更新
    this.updateActiveLink(url.pathname);

    // クリックされたリンクのIDが "bottom-navbar-notifications-link" ならば5秒後に未読カウントを非表示にする
    if (event.currentTarget.id === "bottom-navbar-notifications-link") {
      this.hideUnreadCountAfterDelay();
    }
  }

  handlePopState(event) {
    const state = event.state;
    if (state && state.url) {
      // Turboフレームでの遷移
      document.querySelector("#main-content").src = state.url;
      // アクティブなリンクを更新
      this.updateActiveLink(state.url);
    }
  }

  updateActiveLink(url) {
    const links = [
      "bottom-navbar-home-link",
      "bottom-navbar-profile-link",
      "bottom-navbar-notifications-link",
      "bottom-navbar-messages-link",
      "bottom-navbar-settings-link",
    ];

    links.forEach((id) => {
      const link = document.getElementById(id);
      if (link) {
        if (link.pathname === url) {
          link.classList.add(
            "font-bold",
            "border-b-4",
            "border-sky-400-accent",
            "text-blue-500"
          );
          link.classList.remove("font-medium", "border-b-2", "border-gray-200");
        } else {
          link.classList.remove(
            "font-bold",
            "border-b-4",
            "border-sky-400-accent",
            "text-blue-500"
          );
          link.classList.add("font-medium", "border-b-2", "border-gray-200");
        }
      }
    });
  }

  hideUnreadCountAfterDelay() {
    setTimeout(() => {
      const unreadCountElement = document.querySelector(
        "#bottom-navbar-notifications-link .absolute"
      );
      if (unreadCountElement) {
        unreadCountElement.style.display = "none";
      }
    }, 5000); // 5秒後に実行
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.updateActiveLinks(window.location.pathname);
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
    this.updateActiveLinks(url.pathname);

    // 特定のリンクIDの場合の処理
    this.specialLinkHandler(event.currentTarget.id);
  }

  handlePopState(event) {
    const state = event.state;
    if (state && state.url) {
      // Turboフレームでの遷移
      document.querySelector("#main-content").src = state.url;
      // アクティブなリンクを更新
      this.updateActiveLinks(state.url);
    }
  }

  updateActiveLinks(url) {
    const links = this.getAllLinks();
    links.forEach((link) => {
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
    });
  }

  getAllLinks() {
    return [
      ...document.querySelectorAll(
        "#header-logo-link, #header-about-link, #header-home-link, #header-profile-link, #header-users-link, #header-notifications-link, #header-settings-link, #header-logout-link, #header-delete-account-link"
      ),
      ...document.querySelectorAll(
        "#sidebar-profile-avatar-link, #sidebar-posts-link, #sidebar-profile-link, #sidebar-notifications-link, #sidebar-settings-link, #sidebar-new-post-link"
      ),
      ...document.querySelectorAll(
        "#bottom-navbar-home-link, #bottom-navbar-profile-link, #bottom-navbar-notifications-link, #bottom-navbar-messages-link, #bottom-navbar-settings-link"
      ),
    ].filter((link) => link !== null);
  }

  specialLinkHandler(id) {
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

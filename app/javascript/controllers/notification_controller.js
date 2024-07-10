// app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notificationCount"];

  connect() {
    this.updateActiveLink();
    this.updateUnreadNotifications(); // 初期の未読通知数を設定

    document.addEventListener("turbo:load", this.updateActiveLink.bind(this));

    // 60秒ごとに未読通知数を更新
    this.notificationInterval = setInterval(() => {
      this.updateUnreadNotifications();
    }, 60000);
  }

  disconnect() {
    document.removeEventListener(
      "turbo:load",
      this.updateActiveLink.bind(this)
    );
    clearInterval(this.notificationInterval);
  }

  updateActiveLink() {
    const activeLinks = document.querySelectorAll(".active-link");
    activeLinks.forEach((link) => link.classList.remove("active-link"));

    const currentPath = window.location.pathname;
    const links = document.querySelectorAll(
      "a[data-action='click->navbar#setActive']"
    );
    links.forEach((link) => {
      if (link.getAttribute("href") === currentPath) {
        link.classList.add("active-link");
      }
    });
  }

  setActive(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const url = new URL(target.href);
    history.pushState({}, "", url);

    this.updateActiveLink();
  }

  async updateUnreadNotifications() {
    try {
      const response = await fetch("/notifications/unread_count", {
        cache: "no-store",
      });
      const data = await response.json();
      this.renderUnreadCount(data.unread_count);
    } catch (error) {
      console.error("Failed to fetch unread notifications count:", error);
    }
  }

  renderUnreadCount(count) {
    const unreadCountElements = document.querySelectorAll(
      "[data-notification-target='notificationCount']"
    );
    unreadCountElements.forEach((element) => {
      element.textContent = count;
      if (count > 0) {
        element.style.display = "block";
      } else {
        element.style.display = "none";
      }
    });
  }
}

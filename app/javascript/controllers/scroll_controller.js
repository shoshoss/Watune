import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["detailButton", "backButton"];

  connect() {
    this.restoreScrollPosition();
    document.addEventListener("turbo:before-cache", this.saveScrollPosition);
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.saveScrollPosition);
  }

  saveScrollPosition = () => {
    const mainContent = document.querySelector("main");
    if (mainContent) {
      localStorage.setItem("scrollPosition", mainContent.scrollTop);
    }
  };

  restoreScrollPosition = () => {
    const scrollPosition = localStorage.getItem("scrollPosition");
    if (scrollPosition) {
      const mainContent = document.querySelector("main");
      if (mainContent) {
        mainContent.scrollTop = parseInt(scrollPosition, 10);
        localStorage.removeItem("scrollPosition");
      }
    }
  };

  handleDetailClick(event) {
    const postId = event.currentTarget.dataset.postId;
    localStorage.setItem("postId", postId);
    this.saveScrollPosition();
  }

  handleBackClick(event) {
    this.restoreScrollPosition();
  }
}

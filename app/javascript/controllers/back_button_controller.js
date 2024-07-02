import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.saveCurrentState();
    document.addEventListener(
      "turbo:before-cache",
      this.saveScrollPosition.bind(this)
    );
    window.addEventListener("popstate", this.handlePopState.bind(this));

    // デバッグ用ログ
    console.log("BackButtonController connected");

    // 戻るボタンのイベントリスナーを追加
    const backButton = document.getElementById("back-button");
    if (backButton) {
      backButton.addEventListener(
        "click",
        this.handleBackButtonClick.bind(this)
      );
    }
  }

  disconnect() {
    document.removeEventListener(
      "turbo:before-cache",
      this.saveScrollPosition.bind(this)
    );
    window.removeEventListener("popstate", this.handlePopState.bind(this));
  }

  saveCurrentState() {
    const frame = document.getElementById("main-content");
    if (frame) {
      const postId = this.getCurrentPostId(); // 現在のポストIDを取得
      history.replaceState(
        { turboFrame: frame.src, postId: postId },
        "",
        window.location.href
      );
    }
  }

  getCurrentPostId() {
    const postElement = document.querySelector("[data-post-id]");
    return postElement ? postElement.dataset.postId : null;
  }

  saveScrollPosition() {
    const repliesContainer = document.getElementById("replies");
    if (repliesContainer) {
      sessionStorage.setItem(
        "repliesScrollPosition",
        repliesContainer.scrollTop
      );
    }
  }

  restoreScrollPosition() {
    const repliesContainer = document.getElementById("replies");
    const savedScrollPosition = sessionStorage.getItem("repliesScrollPosition");
    if (repliesContainer && savedScrollPosition !== null) {
      repliesContainer.scrollTop = savedScrollPosition;
      sessionStorage.removeItem("repliesScrollPosition");
    }
  }

  handlePopState(event) {
    const frame = document.getElementById("main-content");
    if (frame && event.state && event.state.turboFrame) {
      frame.src = event.state.turboFrame;
      const postId = event.state.postId;
      if (postId) {
        const postElement = document.querySelector(`[id='${postId}']`);
        if (postElement) {
          postElement.scrollIntoView({ behavior: "smooth" });
        }
      }
    }
  }

  handleBackButtonClick(event) {
    event.preventDefault();
    console.log("Back button clicked");

    // 履歴を戻す
    window.history.back();
  }
}

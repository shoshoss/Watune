import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  connect() {
    this.saveCurrentURL();
    document.addEventListener("turbo:before-cache", this.saveScrollPosition);
    document.addEventListener(
      "turbo:load",
      this.restoreScrollPosition.bind(this)
    );
    this.setupBackButton();
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.saveScrollPosition);
    document.removeEventListener(
      "turbo:load",
      this.restoreScrollPosition.bind(this)
    );
  }

  saveCurrentURL() {
    const frame = document.getElementById("main-content");
    if (frame) {
      history.replaceState({ turboFrame: frame.src }, "", window.location.href);
    }
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
    const scrollToTopButton = document.getElementById("scroll-to-top");
    const scrollToBottomButton = document.getElementById("scroll-to-bottom");

    function scrollToTop() {
      repliesContainer.scrollTop = 0;
    }

    function scrollToBottom() {
      repliesContainer.scrollTop = repliesContainer.scrollHeight;
    }

    function checkScroll() {
      if (repliesContainer.scrollHeight > repliesContainer.clientHeight) {
        scrollToTopButton.style.display = "block";
        scrollToBottomButton.style.display = "block";
      } else {
        scrollToTopButton.style.display = "none";
        scrollToBottomButton.style.display = "none";
      }
    }

    if (scrollToTopButton && scrollToBottomButton && repliesContainer) {
      scrollToTopButton.addEventListener("click", scrollToTop);
      scrollToBottomButton.addEventListener("click", scrollToBottom);

      // ページロード時にスクロールをチェック
      checkScroll();

      // 新しい返信が追加されたときにスクロールをチェック
      const observer = new MutationObserver(function (mutationsList, observer) {
        for (let mutation of mutationsList) {
          if (mutation.type === "childList") {
            checkScroll();
            if (scrollToBottomButton.style.display === "block") {
              scrollToBottom();
            }
          }
        }
      });

      observer.observe(repliesContainer, { childList: true, subtree: true });

      // 前回のスクロール位置を復元
      const savedScrollPosition = sessionStorage.getItem(
        "repliesScrollPosition"
      );
      if (savedScrollPosition !== null) {
        repliesContainer.scrollTop = savedScrollPosition;
        sessionStorage.removeItem("repliesScrollPosition");
      }
    }
  }

  setupBackButton() {
    const backButton = document.getElementById("back-button");

    if (backButton) {
      backButton.addEventListener("click", (event) => {
        event.preventDefault();
        const previousState = history.state;
        if (previousState && previousState.turboFrame) {
          const frame = document.getElementById("main-content");
          if (frame) {
            frame.src = previousState.turboFrame;
            history.back();
          }
        } else {
          window.history.back();
        }
      });
    }
  }
}

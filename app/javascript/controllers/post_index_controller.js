import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.saveScrollPosition = this.saveScrollPosition.bind(this);
    this.restoreScrollPosition = this.restoreScrollPosition.bind(this);

    // スクロール位置を復元
    this.restoreScrollPosition();

    // スクロール位置を保存
    window.addEventListener("scroll", this.saveScrollPosition);
    document.addEventListener("turbo:before-cache", this.saveScrollPosition);
  }

  disconnect() {
    // イベントリスナーを解除
    window.removeEventListener("scroll", this.saveScrollPosition);
    document.removeEventListener("turbo:before-cache", this.saveScrollPosition);
  }

  saveScrollPosition() {
    const category =
      new URLSearchParams(window.location.search).get("category") ||
      "recommended";
    localStorage.setItem(`scrollPosition-${category}`, window.scrollY);
    console.log(
      `Saving scroll position for category ${category}: ${window.scrollY}`
    );
  }

  restoreScrollPosition() {
    const category =
      new URLSearchParams(window.location.search).get("category") ||
      "recommended";
    const scrollPosition = localStorage.getItem(`scrollPosition-${category}`);
    console.log(
      `Restoring scroll position for category ${category}: ${scrollPosition}`
    );
    if (scrollPosition) {
      window.scrollTo(0, parseInt(scrollPosition, 10));
    }
  }

  saveState(event) {
    const category = event.currentTarget.getAttribute("href").split("=")[1];
    this.saveScrollPosition();
    localStorage.setItem("selectedCategory", category);
    console.log(`Category selected: ${category}`);
  }
}

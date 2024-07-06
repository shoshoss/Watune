import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.saveScrollPosition = this.saveScrollPosition.bind(this);
    this.restoreScrollPosition = this.restoreScrollPosition.bind(this);
    this.handleCategoryTabs = this.handleCategoryTabs.bind(this);

    // スクロール位置を復元
    this.restoreScrollPosition();

    // スクロール位置を保存
    window.addEventListener("scroll", this.saveScrollPosition);
    document.addEventListener("turbo:before-cache", this.saveScrollPosition);

    // カテゴリータブの固定処理
    this.handleCategoryTabs();
    window.addEventListener("scroll", this.handleCategoryTabs);
  }

  disconnect() {
    // イベントリスナーを解除
    window.removeEventListener("scroll", this.saveScrollPosition);
    document.removeEventListener("turbo:before-cache", this.saveScrollPosition);
    window.removeEventListener("scroll", this.handleCategoryTabs);
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

  handleCategoryTabs() {
    const categoryTabsWrapper = document.getElementById(
      "post-category-tabs-wrapper"
    );
    const categoryTabs = document.getElementById("post-category-tabs");

    if (categoryTabsWrapper && categoryTabs) {
      const categoryTabsOffsetTop = categoryTabsWrapper.offsetTop;

      if (window.scrollY > categoryTabsOffsetTop) {
        categoryTabsWrapper.style.height = categoryTabs.offsetHeight + "px";
        categoryTabs.classList.add(
          "fixed",
          "top-0",
          "left-0",
          "w-full",
          "bg-white",
          "shadow-md",
          "z-10"
        );
      } else {
        categoryTabsWrapper.style.height = "auto";
        categoryTabs.classList.remove(
          "fixed",
          "top-0",
          "left-0",
          "w-full",
          "bg-white",
          "shadow-md",
          "z-10"
        );
      }
    }
  }

  saveState(event) {
    event.preventDefault(); // デフォルトのリンク動作を防止
    const category = event.currentTarget.getAttribute("href").split("=")[1];
    this.saveScrollPosition();
    localStorage.setItem("selectedCategory", category);
    Turbo.visit(event.currentTarget.getAttribute("href"));
  }
}

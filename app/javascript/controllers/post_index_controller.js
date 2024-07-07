import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // クラス内のプロパティを定義
  static targets = ["tab"];

  connect() {
    this.initializePage();
  }

  // ページの初期化
  initializePage() {
    this.handleNavbarOpacity();
    this.handleCategoryTabs();
    this.restoreTabState();
  }

  // ナビバーの透明度を制御
  handleNavbarOpacity() {
    const navbar = document.getElementById("bottom-navbar");
    if (!navbar) return;

    let lastScrollTop = 0;
    window.addEventListener("scroll", () => {
      const scrollTop =
        window.pageYOffset || document.documentElement.scrollTop;
      navbar.style.opacity = scrollTop > lastScrollTop ? "0.5" : "1";
      lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
    });
  }

  // カテゴリータブの固定を制御
  handleCategoryTabs() {
    const categoryTabsWrapper = document.getElementById(
      "post-category-tabs-wrapper"
    );
    const categoryTabs = document.getElementById("post-category-tabs");
    if (!categoryTabsWrapper || !categoryTabs) return;

    const categoryTabsOffsetTop = categoryTabsWrapper.offsetTop;
    window.addEventListener("scroll", () => {
      if (window.pageYOffset > categoryTabsOffsetTop) {
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
    });
  }

  // タブの状態を保存
  saveTabState(event) {
    event.preventDefault();
    const category = event.currentTarget.href.split("category=")[1];
    const container = document.getElementById("post-category-tabs-container");
    if (container) {
      localStorage.setItem("tabScrollPosition", container.scrollLeft);
    }
    localStorage.setItem("selectedCategory", category);

    // Turbo Frameのロードをトリガー
    Turbo.visit(event.currentTarget.href, { frame: "open-posts" });
  }

  // タブの状態を復元
  restoreTabState() {
    const container = document.getElementById("post-category-tabs-container");
    const scrollPosition = localStorage.getItem("tabScrollPosition");
    if (container && scrollPosition) {
      container.scrollLeft = parseInt(scrollPosition);
    }

    const selectedCategory = localStorage.getItem("selectedCategory");
    if (selectedCategory) {
      this.tabTargets.forEach((tab) => {
        if (tab.href.includes(selectedCategory)) {
          tab.classList.add("active");
        } else {
          tab.classList.remove("active");
        }
      });
    }
  }
}

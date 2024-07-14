import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initializePage();
    this.updateActiveTab();
    window.addEventListener("popstate", this.updateActiveTab.bind(this));

    // Turbo Frame Loadedイベントリスナーを追加
    document.addEventListener(
      "turbo:frame-load",
      this.updateActiveTab.bind(this)
    );
  }

  // ページの初期化
  initializePage() {
    this.handleNavbarOpacity();
    this.handleCategoryTabs();
  }

  // ナビバーの透明度を制御
  handleNavbarOpacity() {
    const navbar = document.getElementById("bottom-navbar");
    if (!navbar) return;

    let lastScrollTop = 0;
    window.addEventListener("scroll", () => {
      const scrollTop = window.scrollY || document.documentElement.scrollTop;
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
    });
  }

  // アクティブなタブを更新
  updateActiveTab() {
    const currentCategory =
      new URLSearchParams(window.location.search).get("category") ||
      "recommended";
    const tabIds = [
      "recommended",
      "praise_gratitude",
      "music",
      "child",
      "skill",
      "favorite",
      "monologue",
      "other",
    ];

    tabIds.forEach((category) => {
      const tab = document.getElementById(`tab-${category}`);
      if (tab) {
        if (category === currentCategory) {
          tab.classList.add("active");
        } else {
          tab.classList.remove("active");
        }
      }
    });

    // アクティブなタブが見えるようにスクロール
    const activeTab = document.querySelector(".c-post-tab.active");
    if (activeTab) {
      const container = document.getElementById("post-category-tabs-container");
      container.scrollTo({
        left:
          activeTab.offsetLeft -
          container.offsetWidth / 2 +
          activeTab.offsetWidth / 2,
        behavior: "smooth",
      });
    }
  }
}

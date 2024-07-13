// app/javascript/controllers/profile_show_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab"];

  connect() {
    this.initializePage();
    // popstateイベントを監視してURLが変わったときにタブのアクティブ状態を更新する
    window.addEventListener("popstate", this.updateActiveTabFromUrl.bind(this));
  }

  // ページの初期化
  initializePage() {
    this.handleNavbarOpacity();
    this.handleCategoryTabs();
    this.restoreTabState();
    this.updateActiveTab(this.getCurrentCategory());
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
      "profile-category-tabs-wrapper"
    );
    const categoryTabs = document.getElementById("profile-category-tabs");
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

  // タブの状態を保存
  saveTabState(event) {
    event.preventDefault(); // デフォルトのリンク動作を無効化
    const category = event.currentTarget.href.split("category=")[1];
    if (!category) {
      // カテゴリーが取得できない場合はクッキーのURLで更新
      const savedCategory = this.getCookieValue(
        this.getCookieName("selectedCategory")
      );
      if (savedCategory) {
        const newUrl = `${window.location.pathname}?category=${savedCategory}`;
        Turbo.visit(newUrl, { frame: "_top" });
      }
      return;
    }

    const container = document.getElementById(
      "profile-category-tabs-container"
    );
    if (container) {
      const maxScrollLeft = container.scrollWidth - container.clientWidth - 180; // 180pxの余白を考慮
      const scrollPosition = Math.min(container.scrollLeft, maxScrollLeft);
      document.cookie = `${this.getCookieName(
        "tabScrollPosition"
      )}=${scrollPosition}; path=/; max-age=31536000`;
      console.log(`タブのスクロール位置を保存: ${scrollPosition}`);
    }

    // Turbo Driveのロードをトリガー
    Turbo.visit(event.currentTarget.href, { frame: "_top" });

    // アクティブなタブを更新
    this.updateActiveTab(category);
  }

  // タブの状態を復元
  restoreTabState() {
    const container = document.getElementById(
      "profile-category-tabs-container"
    );
    const scrollPosition = this.getCookieValue(
      this.getCookieName("tabScrollPosition")
    );
    if (container && scrollPosition !== null) {
      const parsedScrollPosition = parseFloat(scrollPosition);
      console.log(`タブのスクロール位置を復元: ${parsedScrollPosition}`);
      // スクロール位置が正しく反映されるまで待機してからスクロールを実行
      requestAnimationFrame(() => {
        container.scrollTo({ left: parsedScrollPosition, behavior: "auto" }); // スムーススクロールではなく、即座にスクロールする
      });
    }

    const selectedCategory = this.getCurrentCategory();
    if (selectedCategory) {
      this.updateActiveTab(selectedCategory);
    }
  }

  // 現在のカテゴリーを取得
  getCurrentCategory() {
    const urlParams = new URLSearchParams(window.location.search);
    const categoryFromUrl = urlParams.get("category");
    const categoryFromCookies = this.getCookieValue(
      this.getCookieName("selectedCategory")
    );

    return (
      categoryFromUrl ||
      categoryFromCookies ||
      (this.isCurrentUser() ? "all_my_posts" : "my_posts_open")
    );
  }

  // アクティブなタブを更新
  updateActiveTab(selectedCategory) {
    const category = selectedCategory || "my_posts_open";
    this.tabTargets.forEach((tab) => {
      if (tab.href.includes(category)) {
        tab.classList.add("active");
      } else {
        tab.classList.remove("active");
      }
    });
  }

  // URLが変更されたときにアクティブなタブを更新
  updateActiveTabFromUrl() {
    const category = this.getCurrentCategory();
    this.updateActiveTab(category);
  }

  // クッキーの値を取得するヘルパーメソッド
  getCookieValue(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(";").shift();
    return null;
  }

  // クッキー名を生成するヘルパーメソッド
  getCookieName(key) {
    return `${this.getUsernameSlug()}_${key}`;
  }

  // 新しいメソッドでusername_slugを取得
  getUsernameSlug() {
    const urlParts = window.location.pathname.split("/");
    return urlParts.length > 1 ? urlParts[1] : "";
  }

  // 現在のユーザーかどうかを判定
  isCurrentUser() {
    const urlParts = window.location.pathname.split("/");
    const usernameSlug = urlParts.length > 1 ? urlParts[1] : "";
    return usernameSlug === this.getCurrentUsernameSlug();
  }

  // 現在のユーザーのusername_slugを取得
  getCurrentUsernameSlug() {
    return document.querySelector('meta[name="current-user-username-slug"]')
      .content;
  }
}

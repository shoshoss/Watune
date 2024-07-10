import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // ターゲットを定義
  static targets = ["tab"];

  connect() {
    this.initializePage();
    // popstateイベントを監視してURLが変わったときにタブのアクティブ状態を更新する
    window.addEventListener("popstate", this.updateActiveTabFromUrl.bind(this));
    // 初期ロード時にクッキーを確認してリダイレクト
    this.redirectToCategoryFromCookie();
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
    if (!category) return; // カテゴリーが取得できない場合は何もしない

    const container = document.getElementById(
      "profile-category-tabs-container"
    );
    if (container) {
      const maxScrollLeft = container.scrollWidth - container.clientWidth - 180; // 180pxの余白を考慮
      const scrollPosition = Math.min(container.scrollLeft, maxScrollLeft);
      localStorage.setItem(
        this.getStorageKey("tabScrollPosition"),
        scrollPosition
      );
      console.log(`タブのスクロール位置を保存: ${scrollPosition}`);
    }
    localStorage.setItem(this.getStorageKey("selectedCategory"), category);

    // Turbo Frameのロードをトリガー
    Turbo.visit(event.currentTarget.href, { frame: "main-content" });

    // 必要な場合のみクッキーを設定
    if (this.getCurrentCategory() !== category) {
      this.setCategoryCookie(category);
    }

    // アクティブなタブを更新
    this.updateActiveTab(category);

    // URLを手動で更新
    history.pushState(null, "", event.currentTarget.href);
  }

  // タブの状態を復元
  restoreTabState() {
    const container = document.getElementById(
      "profile-category-tabs-container"
    );
    const scrollPosition = localStorage.getItem(
      this.getStorageKey("tabScrollPosition")
    );
    if (container && scrollPosition !== null) {
      const parsedScrollPosition = parseFloat(scrollPosition);
      console.log(`タブのスクロール位置を復元: ${parsedScrollPosition}`);
      // スクロール位置が正しく反映されるまで待機してからスクロールを実行
      requestAnimationFrame(() => {
        container.scrollTo({
          left: parsedScrollPosition,
          behavior: "auto", // スムーススクロールではなく、即座にスクロールする
        });
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
    const categoryFromCookie = document.cookie
      .split("; ")
      .find((row) =>
        row.startsWith(this.getCookieKey("selected_profile_category="))
      )
      ?.split("=")[1];
    const categoryFromLocalStorage = localStorage.getItem(
      this.getStorageKey("selectedCategory")
    );

    return (
      categoryFromUrl ||
      categoryFromCookie ||
      categoryFromLocalStorage ||
      (this.isCurrentUser() ? "all_my_posts" : "my_posts_open")
    );
  }

  // 選択されたカテゴリーをサーバーに送信
  setCategoryCookie(selectedCategory) {
    const category =
      selectedCategory || this.getCurrentCategory() || "my_posts_open";
    const expires = new Date();
    expires.setTime(expires.getTime() + 365 * 24 * 60 * 60 * 1000); // 1年間有効
    document.cookie = `${this.getCookieKey(
      "selected_profile_category="
    )}${category}; path=/; expires=${expires.toUTCString()}; SameSite=Lax;`;
    localStorage.setItem(this.getStorageKey("selectedCategory"), category);
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

  // クッキーからカテゴリーを取得してリダイレクト
  redirectToCategoryFromCookie() {
    const currentPath = window.location.pathname + window.location.search;
    const currentCategory = this.getCurrentCategory();

    if (
      !currentPath.includes(`category=${currentCategory}`) &&
      currentCategory !==
        (this.isCurrentUser() ? "all_my_posts" : "my_posts_open")
    ) {
      const usernameSlug = this.getUsernameSlug(); // 新しいメソッドでusername_slugを取得
      const newUrl = `/${usernameSlug}?category=${currentCategory}`;
      Turbo.visit(newUrl, { frame: "main-content" });
      this.updateActiveTab(currentCategory);
    }
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

  // ストレージキーを取得
  getStorageKey(key) {
    return `${this.getUsernameSlug()}_${key}`;
  }

  // クッキーキーを取得
  getCookieKey(key) {
    return `${this.getUsernameSlug()}_${key}`;
  }
}

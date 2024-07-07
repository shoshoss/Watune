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
    this.setCategoryCookie();
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

  // タブの状態を保存
  saveTabState(event) {
    event.preventDefault(); // デフォルトのリンク動作を無効化
    const category = event.currentTarget.href.split("category=")[1];
    const container = document.getElementById("post-category-tabs-container");
    if (container) {
      const maxScrollLeft = container.scrollWidth - container.clientWidth - 180; // 180pxの余白を考慮
      const scrollPosition = Math.min(container.scrollLeft, maxScrollLeft);
      localStorage.setItem("tabScrollPosition", scrollPosition);
      console.log(`タブのスクロール位置を保存: ${scrollPosition}`);
    }
    localStorage.setItem("selectedCategory", category);

    // Turbo Frameのロードをトリガー
    Turbo.visit(event.currentTarget.href, { frame: "_top" });

    // 選択されたカテゴリーをサーバーに送信
    this.setCategoryCookie();
    // アクティブなタブを更新
    this.updateActiveTab(category);
  }

  // タブの状態を復元
  restoreTabState() {
    const container = document.getElementById("post-category-tabs-container");
    const scrollPosition = localStorage.getItem("tabScrollPosition");
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
      .find((row) => row.startsWith("selected_category="))
      ?.split("=")[1];

    return categoryFromUrl || categoryFromCookie || "recommended";
  }

  // 選択されたカテゴリーをサーバーに送信
  setCategoryCookie() {
    const selectedCategory = this.getCurrentCategory();
    document.cookie = `selected_category=${selectedCategory}; path=/`;
  }

  // アクティブなタブを更新
  updateActiveTab(selectedCategory) {
    this.tabTargets.forEach((tab) => {
      if (tab.href.includes(selectedCategory)) {
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
      currentCategory !== "recommended"
    ) {
      const newUrl = `/waves?category=${currentCategory}`;
      Turbo.visit(newUrl, { frame: "_top" });
      this.updateActiveTab(currentCategory);
    }
  }
}

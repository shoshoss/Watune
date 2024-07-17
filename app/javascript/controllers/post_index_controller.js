import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  static targets = ["categoryContent"];
  static values = { loading: Boolean };

  connect() {
    this.initializePage();
    this.updateActiveTab();
    window.addEventListener("popstate", this.handlePopState.bind(this));
    window.addEventListener("beforeunload", this.saveScrollPosition.bind(this));
    window.addEventListener("scroll", this.handleScroll.bind(this));
    this.scrollPositions = this.loadScrollPositions();
    this.cachedData = {}; // データキャッシュ用のオブジェクト
    this.loadedCategories = new Set([this.getCurrentCategory()]);

    console.log("Controller connected");
  }

  // ページの初期化
  initializePage() {
    this.handleNavbarOpacity();
    this.handleCategoryTabs();
  }

  // スクロールイベントを処理するメソッド
  handleScroll() {
    const scrollTop = window.scrollY || document.documentElement.scrollTop;
    this.handleNavbarOpacity(scrollTop);
    this.handleCategoryTabs(scrollTop);
  }

  // ナビバーの透明度を制御
  handleNavbarOpacity(scrollTop) {
    const navbar = document.getElementById("bottom-navbar");
    if (!navbar) return;

    navbar.style.opacity = scrollTop > this.lastScrollTop ? "0.5" : "1";
    this.lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
  }

  // カテゴリータブの固定を制御
  handleCategoryTabs(scrollTop) {
    const categoryTabsWrapper = document.getElementById(
      "post-category-tabs-wrapper"
    );
    const categoryTabs = document.getElementById("post-category-tabs");
    if (!categoryTabsWrapper || !categoryTabs) return;

    const categoryTabsOffsetTop = categoryTabsWrapper.offsetTop;
    if (scrollTop > categoryTabsOffsetTop) {
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

  // カテゴリーを切り替える
  switchCategory(event) {
    event.preventDefault();
    const category = event.currentTarget.dataset.category;

    // 現在のカテゴリーのスクロール位置を保存
    const currentCategory = this.getCurrentCategory();
    this.scrollPositions[currentCategory] = window.scrollY;

    // URLとCookieを更新
    const url = new URL(window.location);
    url.searchParams.set("category", category);
    history.pushState({ category }, "", url); // 履歴に状態を追加
    Cookies.set("selected_post_category", category, { expires: 365 });

    // アクティブタブを更新
    this.updateActiveTab();

    // カテゴリーコンテンツの表示を切り替え
    this.toggleCategoryContent(category);

    // スクロール位置を復元
    const scrollPosition = this.scrollPositions[category] || 0;
    window.scrollTo({
      top: scrollPosition,
      behavior: "smooth",
    });

    // カテゴリーのデータがまだ読み込まれていない場合、非同期で取得
    if (!this.loadedCategories.has(category)) {
      this.fetchCategoryPosts(category);
    } else {
      this.displayCategoryPosts(category);
    }
  }

  // 現在のカテゴリーを取得
  getCurrentCategory() {
    return (
      new URLSearchParams(window.location.search).get("category") ||
      Cookies.get("selected_post_category") ||
      "recommended"
    );
  }

  // カテゴリーコンテンツを切り替え
  toggleCategoryContent(category) {
    document.querySelectorAll(".category-posts").forEach((el) => {
      el.classList.add("hidden");
    });

    const selectedCategoryPosts = document.getElementById(`${category}-posts`);
    if (selectedCategoryPosts) {
      selectedCategoryPosts.classList.remove("hidden");
    }
  }

  // カテゴリーの投稿を非同期で取得
  fetchCategoryPosts(category) {
    fetch(`/waves?category=${category}`, {
      headers: {
        Accept: "application/json", // JSON形式での応答を期待
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => response.json()) // JSON形式で応答を解析
      .then((data) => {
        const postsContainer = document.getElementById(`${category}-posts`);
        if (postsContainer) {
          postsContainer.innerHTML = data.html; // 取得したHTMLを挿入
          this.loadedCategories.add(category); // データが読み込まれたカテゴリーを記録
          this.cachedData[category] = data.html; // データをキャッシュ
        }
      })
      .catch((error) => console.error("Error fetching category posts:", error));
  }

  // カテゴリの投稿を表示
  displayCategoryPosts(category) {
    const postsContainer = document.getElementById(`${category}-posts`);
    if (postsContainer && this.cachedData[category]) {
      postsContainer.innerHTML = this.cachedData[category]; // キャッシュされたHTMLを挿入
    }
  }

  // アクティブなタブを更新
  updateActiveTab() {
    const currentCategory = this.getCurrentCategory();
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

    this.scrollToActiveTab();
  }

  // アクティブなタブへスクロール
  scrollToActiveTab() {
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

  // ブラウザの戻るボタンを押した際の処理
  handlePopState(event) {
    const state = event.state;
    if (state && state.category) {
      // カテゴリーの切り替えを行う
      this.switchCategory({
        preventDefault: () => {},
        currentTarget: {
          dataset: {
            category: state.category,
          },
        },
      });
    } else {
      this.updateActiveTab();
      this.showCurrentCategory();
    }
  }

  // 現在のカテゴリーを表示
  showCurrentCategory() {
    const currentCategory = this.getCurrentCategory();

    // すべてのカテゴリーを非表示にする
    document
      .querySelectorAll(".category-posts")
      .forEach((el) => el.classList.add("hidden"));

    // 選択されたカテゴリーを表示する
    const selectedCategoryPosts = document.getElementById(
      `${currentCategory}-posts`
    );
    if (selectedCategoryPosts) {
      selectedCategoryPosts.classList.remove("hidden");
    }

    // スクロール位置を復元
    const scrollPosition = this.scrollPositions[currentCategory] || 0;
    window.scrollTo({
      top: scrollPosition,
      behavior: "smooth",
    });

    // ハッシュが存在する場合、その要素までスクロール
    const hash = window.location.hash;
    if (hash) {
      document.querySelector(hash)?.scrollIntoView({ behavior: "smooth" });
    }
  }

  // スクロール位置を保存
  saveScrollPosition() {
    const currentCategory = this.getCurrentCategory();
    this.scrollPositions[currentCategory] = window.scrollY;
    sessionStorage.setItem(
      "scrollPositions",
      JSON.stringify(this.scrollPositions)
    );
  }

  // スクロール位置を復元
  restoreScrollPosition(category) {
    const scrollPosition = this.scrollPositions[category] || 0;
    window.scrollTo({
      top: scrollPosition,
      behavior: "smooth",
    });
  }

  // スクロール位置をロード
  loadScrollPositions() {
    const scrollPositions = sessionStorage.getItem("scrollPositions");
    return scrollPositions ? JSON.parse(scrollPositions) : {};
  }
}

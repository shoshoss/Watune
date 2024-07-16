// app/javascript/controllers/post_index_controller.js
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

  // カテゴリーを切り替える
  switchCategory(event) {
    event.preventDefault();
    const category = event.currentTarget.dataset.category;
    const currentCategory = this.getCurrentCategory();

    // 同じカテゴリのタブがクリックされた場合、最新のデータを取得して画面上部にスクロール
    if (category === currentCategory) {
      this.fetchCategoryPosts(category, true); // 最新のデータを取得
      window.scrollTo({ top: 0, behavior: "smooth" }); // 画面上部にスクロール
      return;
    }

    // 現在のカテゴリーのスクロール位置を保存
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

    // カテゴリーのデータがキャッシュされていない場合、非同期で取得
    if (!this.cachedData[category]) {
      this.fetchCategoryPosts(category);
    } else {
      this.displayCategoryPosts(category, this.cachedData[category]);
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
  fetchCategoryPosts(category, forceUpdate = false) {
    // forceUpdateがtrueの場合、キャッシュを無視してデータを取得
    if (!forceUpdate && this.cachedData[category]) {
      this.displayCategoryPosts(category, this.cachedData[category]);
      return;
    }

    fetch(`/waves?category=${category}`, {
      headers: {
        Accept: "application/json", // JSON形式での応答を期待
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => response.json()) // JSON形式で応答を解析
      .then((data) => {
        this.cachedData[category] = data.html; // データをキャッシュ
        this.displayCategoryPosts(category, data.html); // 取得したデータを表示
      })
      .catch((error) => console.error("Error fetching category posts:", error));
  }

  // カテゴリの投稿を表示
  displayCategoryPosts(category, html) {
    const postsContainer = document.getElementById(`${category}-posts`);
    if (postsContainer) {
      postsContainer.innerHTML = html; // 取得したHTMLを挿入
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
      this.updateActiveTab();
      this.toggleCategoryContent(state.category);
      this.displayCategoryPosts(
        state.category,
        this.cachedData[state.category]
      );
      const scrollPosition = this.scrollPositions[state.category] || 0;
      window.scrollTo({
        top: scrollPosition,
        behavior: "smooth",
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

  // スクロール位置をロード
  loadScrollPositions() {
    const scrollPositions = sessionStorage.getItem("scrollPositions");
    return scrollPositions ? JSON.parse(scrollPositions) : {};
  }
}

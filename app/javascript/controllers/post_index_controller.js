import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  static targets = ["categoryContent"];

  connect() {
    this.initializePage();
    this.updateActiveTab();
    window.addEventListener("popstate", this.handlePopState.bind(this)); // ブラウザの戻るボタン用のイベントリスナーを追加
    window.addEventListener("beforeunload", this.saveScrollPosition.bind(this)); // ページを離れる前にスクロール位置を保存
    window.addEventListener("scroll", this.handleScroll.bind(this)); // スクロールイベントを処理
    this.scrollPositions = this.loadScrollPositions(); // スクロール位置をセッションストレージから読み込む
    this.cachedData = {}; // データキャッシュ用のオブジェクト
    this.loadedCategories = new Set([this.getCurrentCategory()]); // 読み込まれたカテゴリーを記録

    console.log("Controller connected");
    console.log("Initial category:", this.getCurrentCategory());
    console.log("Initial scroll positions:", this.scrollPositions);
  }

  // ページの初期化
  initializePage() {
    this.handleNavbarOpacity();
  }

  // スクロールイベントを処理するメソッド
  handleScroll() {
    const scrollTop = window.scrollY || document.documentElement.scrollTop;
    this.handleNavbarOpacity(scrollTop); // ナビバーの透明度を調整
  }

  // ナビバーの透明度を制御
  handleNavbarOpacity(scrollTop) {
    const navbar = document.getElementById("bottom-navbar");
    if (!navbar) return;

    navbar.style.opacity = scrollTop > this.lastScrollTop ? "0.5" : "1";
    this.lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
  }

  // カテゴリーを切り替える
  switchCategory(event) {
    event.preventDefault();
    const category = event.currentTarget.dataset.category;

    console.log("Switching category to:", category);

    // 現在のカテゴリーのスクロール位置を保存
    const currentCategory = this.getCurrentCategory();
    this.scrollPositions[currentCategory] = window.scrollY;
    console.log(
      "Saving scroll position for category",
      currentCategory,
      ":",
      window.scrollY
    );
    this.saveScrollPosition();

    // Cookieを更新
    Cookies.set("selected_post_category", category, { expires: 365 });
    console.log("Updated cookies for category:", category);

    // アクティブタブを更新
    this.updateActiveTab();

    // カテゴリーコンテンツの表示を切り替え
    this.toggleCategoryContent(category);

    // スクロール位置を復元
    const scrollPosition = this.scrollPositions[category] || 0;
    console.log(
      "Restoring scroll position for category",
      category,
      ":",
      scrollPosition
    );
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
    return Cookies.get("selected_post_category") || "recommended";
  }

  // カテゴリーコンテンツを切り替え
  toggleCategoryContent(category) {
    console.log("Toggling content for category:", category);
    this.categoryContentTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.category !== category);
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
      "learn",
      "child",
      "skill",
      "favorite",
      "monologue",
      "other",
    ];

    tabIds.forEach((category) => {
      const tab = document.getElementById(`tab-${category}`);
      if (tab) {
        tab.classList.toggle("active", category === currentCategory);
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
    console.log("Handling popstate event:", state);

    if (state && state.category) {
      // カテゴリーの切り替えを行う
      const category = state.category;

      // Cookieを更新
      Cookies.set("selected_post_category", category, { expires: 365 });

      // アクティブタブを更新
      this.updateActiveTab();

      // カテゴリーコンテンツの表示を切り替え
      this.toggleCategoryContent(category);

      // スクロール位置を復元
      if (state.scrollPosition !== undefined) {
        console.log(
          "Restoring scroll position from state:",
          state.scrollPosition
        );
        setTimeout(() => {
          window.scrollTo({ top: state.scrollPosition, behavior: "smooth" });
        }, 0); // 少し遅延させてスクロール位置を復元
      }

      // カテゴリーのデータがまだ読み込まれていない場合、非同期で取得
      if (!this.loadedCategories.has(category)) {
        this.fetchCategoryPosts(category);
      } else {
        this.displayCategoryPosts(category);
      }
    } else {
      this.updateActiveTab();
      this.showCurrentCategory();
    }
  }

  // 現在のカテゴリーを表示
  showCurrentCategory() {
    const currentCategory = this.getCurrentCategory();
    console.log("Showing current category:", currentCategory);

    // すべてのカテゴリーを非表示にする
    this.categoryContentTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    // 選択されたカテゴリーを表示する
    const selectedCategoryPosts = document.getElementById(
      `${currentCategory}-posts`
    );
    if (selectedCategoryPosts) {
      selectedCategoryPosts.classList.remove("hidden");
    }

    // スクロール位置を復元
    const scrollPosition = this.scrollPositions[currentCategory] || 0;
    console.log(
      "Restoring scroll position for current category",
      currentCategory,
      ":",
      scrollPosition
    );
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
    console.log(
      "Scroll position saved for category",
      currentCategory,
      ":",
      window.scrollY
    );
  }

  // スクロール位置を復元
  restoreScrollPosition(category) {
    const scrollPosition = this.scrollPositions[category] || 0;
    console.log(
      "Restoring scroll position for category",
      category,
      ":",
      scrollPosition
    );
    window.scrollTo({
      top: scrollPosition,
      behavior: "smooth",
    });
  }

  // スクロール位置をロード
  loadScrollPositions() {
    const scrollPositions = sessionStorage.getItem("scrollPositions");
    console.log("Loaded scroll positions:", scrollPositions);
    return scrollPositions ? JSON.parse(scrollPositions) : {};
  }
}

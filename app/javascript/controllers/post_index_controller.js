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

    // Turbo Frameのロード完了時にタブを更新
    document.addEventListener(
      "turbo:frame-load",
      this.updateActiveTab.bind(this)
    );

    // 無限スクロールのイベントリスナーを追加
    window.addEventListener("scroll", this.loadMorePosts.bind(this));

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

  switchCategory(event) {
    event.preventDefault();
    const category = event.currentTarget.dataset.category;

    // 現在のカテゴリーのスクロール位置を保存
    const currentCategory = this.getCurrentCategory();
    this.scrollPositions[currentCategory] = window.scrollY;

    // URLとCookieを更新
    const url = new URL(window.location);
    url.searchParams.set("category", category);
    history.pushState({ category }, "", url);
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
  }

  getCurrentCategory() {
    return (
      new URLSearchParams(window.location.search).get("category") ||
      Cookies.get("selected_post_category") ||
      "recommended"
    );
  }

  toggleCategoryContent(category) {
    document.querySelectorAll(".category-posts").forEach((el) => {
      el.classList.add("hidden");
    });

    const selectedCategoryPosts = document.getElementById(`${category}-posts`);
    if (selectedCategoryPosts) {
      selectedCategoryPosts.classList.remove("hidden");

      if (selectedCategoryPosts.dataset.loaded !== "true") {
        this.fetchCategoryPosts(category);
      }
    }
  }

  fetchCategoryPosts(category) {
    fetch(`/waves/fetch_category_posts?category=${category}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => {
        console.log("Response status:", response.status);
        return response.text();
      })
      .then((html) => {
        console.log("Fetched HTML:", html);
        Turbo.renderStreamMessage(html);
      })
      .catch((error) => console.error("Error fetching category posts:", error));
  }

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

  handlePopState(event) {
    const state = event.state;
    if (state && state.category) {
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

  // 無限スクロールでさらに投稿を読み込む
  // 無限スクロールでさらに投稿を読み込む
  loadMorePosts() {
    const currentCategory = this.getCurrentCategory();
    const loadMoreTarget = document.querySelector(
      `#${currentCategory}-load-more`
    );
    if (!loadMoreTarget) {
      console.log(
        `Load more element not found for category: ${currentCategory}`
      );
      return;
    }

    const rect = loadMoreTarget.getBoundingClientRect();
    const isVisible = rect.top - window.innerHeight < 100; // 100px 余裕を持たせる

    console.log("Load more posts:", isVisible, this.loading);

    if (isVisible && !this.loading) {
      this.loading = true;
      const turboFrame = loadMoreTarget.querySelector("turbo-frame");
      if (!turboFrame || !turboFrame.src) {
        console.log("Turbo frame or src not found");
        this.loading = false;
        return;
      }

      try {
        // 相対URLを絶対URLに変換
        const url = new URL(turboFrame.src, window.location.origin);

        // カテゴリ情報をURLに追加
        url.searchParams.set("category", currentCategory);
        url.searchParams.set("page", this.getNextPage());

        console.log("Fetching more posts from:", url.toString());

        fetch(url.toString(), {
          headers: {
            Accept: "text/vnd.turbo-stream.html",
          },
        })
          .then((response) => response.text())
          .then((html) => {
            console.log("Fetched more posts HTML:", html);
            Turbo.renderStreamMessage(html);
            this.loading = false;
          })
          .catch((error) => {
            console.error("Error loading more posts:", error);
            this.loading = false;
          });
      } catch (e) {
        console.error("Invalid URL:", turboFrame.src);
        this.loading = false;
      }
    }
  }
}

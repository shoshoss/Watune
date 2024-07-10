import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["tab"];

  connect() {
    this.initializePage();
    window.addEventListener("popstate", this.updateActiveTabFromUrl.bind(this));
    this.redirectToCategoryFromCookie();
  }

  initializePage() {
    this.handleNavbarOpacity();
    this.handleCategoryTabs();
    this.restoreTabState();
    this.setCategoryCookie();
  }

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

  saveTabState(event) {
    event.preventDefault();
    const category = event.currentTarget.href.split("category=")[1];
    const container = document.getElementById("post-category-tabs-container");
    if (container) {
      const maxScrollLeft = container.scrollWidth - container.clientWidth - 180;
      const scrollPosition = Math.min(container.scrollLeft, maxScrollLeft);
      localStorage.setItem("tabScrollPosition", scrollPosition);
      console.log(`タブのスクロール位置を保存: ${scrollPosition}`);
    }
    localStorage.setItem("selectedCategory", category);
    Turbo.visit(event.currentTarget.href, { frame: "_top" });
    this.setCategoryCookie(category);
    this.updateActiveTab(category);
  }

  restoreTabState() {
    const container = document.getElementById("post-category-tabs-container");
    const scrollPosition = localStorage.getItem("tabScrollPosition");
    if (container && scrollPosition !== null) {
      const parsedScrollPosition = parseFloat(scrollPosition);
      console.log(`タブのスクロール位置を復元: ${parsedScrollPosition}`);
      requestAnimationFrame(() => {
        container.scrollTo({
          left: parsedScrollPosition,
          behavior: "auto",
        });
      });
    }

    const selectedCategory = this.getCurrentCategory();
    this.updateActiveTab(selectedCategory);
  }

  getCurrentCategory() {
    const urlParams = new URLSearchParams(window.location.search);
    const categoryFromUrl = urlParams.get("category");
    const categoryFromCookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith("selected_post_category="))
      ?.split("=")[1];
    const categoryFromLocalStorage = localStorage.getItem("selectedCategory");

    return (
      categoryFromUrl ||
      categoryFromCookie ||
      categoryFromLocalStorage ||
      "recommended"
    );
  }

  setCategoryCookie(selectedCategory) {
    const category = selectedCategory || "recommended";
    const expires = new Date();
    expires.setTime(expires.getTime() + 365 * 24 * 60 * 60 * 1000);
    document.cookie = `selected_post_category=${category}; path=/; expires=${expires.toUTCString()}; SameSite=Lax;`;
  }

  updateActiveTab(selectedCategory) {
    const category = selectedCategory || "recommended";
    this.tabTargets.forEach((tab) => {
      if (tab.href.includes(category)) {
        tab.classList.add("active");
      } else {
        tab.classList.remove("active");
      }
    });
  }

  updateActiveTabFromUrl() {
    const category = this.getCurrentCategory();
    this.updateActiveTab(category);
  }

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
    } else if (currentCategory === "recommended") {
      this.updateActiveTab("recommended");
    }
  }
}

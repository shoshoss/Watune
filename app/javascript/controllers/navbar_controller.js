import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener(
      "turbo:frame-load",
      this.updateActiveLink.bind(this)
    );
  }

  disconnect() {
    document.removeEventListener(
      "turbo:frame-load",
      this.updateActiveLink.bind(this)
    );
  }

  updateActiveLink() {
    const activeLinks = document.querySelectorAll(".active");
    activeLinks.forEach((link) =>
      link.classList.remove(
        "text-blue-500",
        "font-bold",
        "border-b-4",
        "border-sky-400-accent",
        "active"
      )
    );

    const links = document.querySelectorAll("a[data-corresponding-link-id]");
    links.forEach((link) => {
      const correspondingLinkId = link.getAttribute(
        "data-corresponding-link-id"
      );
      const correspondingLink = document.getElementById(correspondingLinkId);
      if (window.location.pathname === link.pathname) {
        link.classList.add(
          "text-blue-500",
          "font-bold",
          "border-b-4",
          "border-sky-400-accent",
          "active"
        );
        if (correspondingLink) {
          correspondingLink.classList.add("text-blue-500", "active");
        }
      }
    });
  }

  setActive(event) {
    event.preventDefault();

    const target = event.currentTarget;
    const url = new URL(target.href);
    const frame = document.querySelector("turbo-frame#main-content");

    // Turbo Frameのsrcを更新して部分更新
    if (frame) {
      frame.src = url.href;

      // URLを変更する
      history.pushState({}, "", url.href);

      // Turbo Frameの更新が完了した後にアクティブリンクを設定
      frame.addEventListener(
        "turbo:frame-load",
        () => {
          this.updateActiveLink();

          const correspondingLinkId = target.getAttribute(
            "data-corresponding-link-id"
          );
          const correspondingLink =
            document.getElementById(correspondingLinkId);
          if (correspondingLink) {
            correspondingLink.classList.add("text-blue-500", "active");
          }

          target.classList.add(
            "text-blue-500",
            "font-bold",
            "border-b-4",
            "border-sky-400-accent",
            "active"
          );
        },
        { once: true }
      );
    }
  }
}

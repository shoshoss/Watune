import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.handleClick.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick.bind(this));
  }

  handleClick(event) {
    event.preventDefault();

    // 直前のページのURLを取得
    var previousPageUrl = document.referrer;

    // 直前のページが指定されたページかどうかをチェック
    var specifiedPages = [
      "/posts",
      "/posts/recommended",
      "/posts/praise_gratitude",
      "/posts/music",
      "/posts/child",
      "/posts/favorite",
      "/posts/skill",
      "/posts/monologue",
      "/posts/other",
    ];

    if (specifiedPages.some((page) => previousPageUrl.includes(page))) {
      // キャッシュを使用して戻る
      window.location.href = previousPageUrl;
    } else {
      // 通常の戻る動作
      window.history.back();
    }
  }
}

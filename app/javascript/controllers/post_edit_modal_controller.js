import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // 初期設定: コントローラが接続されたときに呼ばれる
  connect() {
    this.element.setAttribute("open", true);
  }

  closeModal() {
    // モーダルを閉じる
    this.element.close();
  }

  afterClose(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }

    // キャッシュをクリアする
    if ("serviceWorker" in navigator && navigator.serviceWorker.controller) {
      navigator.serviceWorker.controller.postMessage({
        action: "clearPostCache",
      });
    }

    // リダイレクト処理
    Turbo.visit(window.location.href, { action: "replace" });
  }
}

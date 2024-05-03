import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ボタンクリック時にモーダルを開く処理
    this.element.setAttribute("open", true);
    // モーダルが開いたときにバックグラウンドをクリックして閉じるイベントを追加
    // this.element.addEventListener("click", this.closeBackground.bind(this));
  }

  closeModal() {
    // モーダルを閉じる
    this.element.close();
  }

  closeBackground(event) {
    // バックグラウンドをクリックしたかどうかをチェック
    if (
      event.target === this.dialogTarget &&
      this.dialogTarget.hasAttribute("open")
    ) {
      console.log("Dialog closed");
      // モーダルを閉じる
      this.closeModal();
    }
  }

  afterClose(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }

    Turbo.visit(window.location.href, { action: "replace" });
  }
}

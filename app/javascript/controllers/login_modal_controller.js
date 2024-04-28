import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ボタンクリック時にモーダルを開く処理
    this.element.setAttribute("open", true);
  }

  closeModal() {
    // モーダルを閉じる
    this.element.removeAttribute("open");
  }

  afterCloseModal(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }
    // モーダルの要素を取得
    const modal = this.element;

    // モーダルがdialog要素の場合、closeメソッドを呼び出す
    if (modal.tagName === "DIALOG") {
      modal.close();
    } else {
      // モーダルがdialog要素でない場合、非表示にする他の方法を使用
      modal.style.display = "none";
    }

    Turbo.visit(window.location.href, { action: "replace" });
  }
}

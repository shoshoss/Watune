import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dialog"];

  connect() {
    // モーダルを開く処理（例えばボタンクリック時などに実行される）
    this.openModal();
    // モーダルが開いたときにバックグラウンドをクリックして閉じるイベントを追加
    this.element.addEventListener("click", this.closeBackground.bind(this));
  }

  openModal() {
    if (this.hasDialogTarget) {
      this.dialogTarget.showModal(); // モーダルを開く
      console.log("Dialog opened");
    } else {
      console.error("Dialog element not found");
    }
  }

  closeModal() {
    if (this.hasDialogTarget && this.dialogTarget.open) {
      this.dialogTarget.close(); // モーダルを閉じる
      console.log("Dialog closed");
    } else {
      console.error("Dialog element not found or dialog not open");
    }
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

  redirectAfterClose(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }

    this.closeModal(); // モーダルを閉じる
    // リダイレクトパスを取得してリダイレクトを実行する
    const redirectPath = this.data.get("redirectPath");
    window.location.href = redirectPath;
  }
}

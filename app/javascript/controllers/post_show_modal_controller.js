import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.setAttribute("open", true);
  }

  closeModal() {
    // モーダルを閉じる
    this.element.close();
  }

  submitEnd(event) {
    console.log("submitEnd called");
    if (event.detail.success) {
      // 成功時にはTurboを無効化してリダイレクトを実行する
      Turbo.session.drive = false;
      const redirectPath =
        event.detail.fetchResponse.response.headers.get("Location");
      if (redirectPath) {
        window.location.href = redirectPath;
      }
    } else {
      // 失敗時にはTurboを有効にしてエラーメッセージを表示する
      Turbo.session.drive = true;
    }
  }
}

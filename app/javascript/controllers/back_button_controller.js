import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("BackButtonController connected");

    // 戻るボタンのイベントリスナーを追加
    const backButton = document.getElementById("back-button");
    if (backButton) {
      backButton.addEventListener(
        "click",
        this.handleBackButtonClick.bind(this)
      );
    }
  }

  handleBackButtonClick(event) {
    event.preventDefault();
    console.log("Back button clicked");

    // 履歴を戻す
    window.history.back();
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = []; // targetsを使用しない

  connect() {
    this.inputElement = document.querySelector("#input-avatar"); // IDでinput要素を取得
    this.previewElement = document.querySelector("#preview-avatar"); // IDでpreview要素を取得
    console.log("PreviewAvatar controller connected");

    // イベントリスナーを登録
    this.inputElement.addEventListener("change", () => this.updatePreview());
  }

  updatePreview() {
    const file = this.inputElement.files[0];
    const preview = this.previewElement;

    if (!file) {
      preview.src = "sample.jpg"; // デフォルトのプレビュー画像
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      alert("ファイルサイズは5MB以下にしてください。");
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      preview.src = event.target.result;
    };
    reader.onerror = () => {
      alert("ファイルの読み込みに失敗しました。");
      preview.src = "sample.jpg"; // エラー時の画像
    };
    reader.readAsDataURL(file);
  }

  disconnect() {
    // イベントリスナーのクリーンアップ
    this.inputElement.removeEventListener("change", () => this.updatePreview());
  }
}

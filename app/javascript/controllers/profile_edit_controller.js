import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "inputAvatar",
    "fileName",
    "previewAvatar",
    "selfIntroduction",
  ];

  connect() {
    console.log("Profile edit controller connected");
    this.setupFileInput();
    this.adjustTextareaHeight(this.selfIntroductionTarget);
  }

  setupFileInput() {
    const input = this.inputAvatarTarget;
    const fileNameDisplay = this.fileNameTargets[0];
    const preview = this.previewAvatarTarget;
    const currentAvatarSrc = preview.src;

    if (!input || !fileNameDisplay || !preview) {
      console.warn("Required elements are not found in the DOM");
      return;
    }

    input.addEventListener("change", (event) => {
      const file = event.target.files[0];
      if (!file) {
        preview.src = currentAvatarSrc;
        fileNameDisplay.textContent = "選択されていません";
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        alert("ファイルサイズは5MB以下にしてください。");
        preview.src = currentAvatarSrc;
        fileNameDisplay.textContent = "選択されていません";
        return;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        preview.src = e.target.result;
        fileNameDisplay.textContent = file.name;
      };
      reader.onerror = () => {
        console.error("エラーが発生しました: ", reader.error);
        alert("ファイルの読み込みに失敗しました。");
        preview.src = currentAvatarSrc;
        fileNameDisplay.textContent = "選択されていません";
      };
      reader.readAsDataURL(file);
    });
  }

  adjustTextareaHeight(textarea) {
    if (!textarea) return;
    textarea.style.height = "auto"; // Reset height
    textarea.style.height = `${textarea.scrollHeight}px`; // Set new height based on content
  }

  adjustHeight(event) {
    this.adjustTextareaHeight(event.target);
  }
}

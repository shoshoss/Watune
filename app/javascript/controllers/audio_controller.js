import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // ドキュメントの play イベントをキャッチ
    document.addEventListener(
      "play",
      (event) => {
        // 全ての audio 要素を取得
        const audios = document.querySelectorAll("audio");
        audios.forEach((audio) => {
          // イベントが発生した audio でなければ停止
          if (audio !== event.target) {
            audio.pause();
          }
        });
      },
      true
    ); // キャプチャフェーズでイベントを処理
  }

  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = this.element.querySelector(`audio[id="audio-${audioId}"]`);

    if (!audio) {
      console.error(`Audio element with ID 'audio-${audioId}' not found.`);
      return;
    }

    // オーディオの再生・停止を切り替え
    if (audio.paused) {
      audio.play().catch((error) => {
        console.error("Playback failed:", error);
      });
    } else {
      audio.pause();
    }
    this.updateIcon(button, !audio.paused);
  }

  updateIcon(button, isPlaying) {
    button.classList.toggle("fa-play", !isPlaying);
    button.classList.toggle("fa-pause", isPlaying);
  }
}

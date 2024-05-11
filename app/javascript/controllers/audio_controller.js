import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.updateAllIconsToPlay(); // 初期化時に全アイコンを再生ボタンに設定
  }

  updateAllIconsToPlay() {
    document.querySelectorAll(".audio-icon").forEach((icon) => {
      icon.classList.remove("fa-pause");
      icon.classList.add("fa-play");
    });
  }

  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    const icon = document.getElementById(`audio-icon-${audioId}`);

    document.querySelectorAll("audio").forEach((a) => {
      if (a.id !== `audio-${audioId}` && !a.paused) {
        a.pause();
        this.updateIcon(
          document.getElementById(`audio-icon-${a.id.replace("audio-", "")}`),
          false
        );
      }
    });

    if (audio.paused) {
      audio
        .play()
        .then(() => {
          this.updateIcon(icon, true);
        })
        .catch((error) => {
          console.error("Playback failed:", error);
          alert(`音声の再生に失敗しました: ${error.message}`);
          this.updateIcon(icon, false);
        });
    } else {
      audio.pause();
      this.updateIcon(icon, false);
    }

    audio.addEventListener("timeupdate", () => {
      this.updateCurrentTimeDisplay(audioId, audio.currentTime);
    });

    // 音声の再生が終了した時のイベントを追加
    audio.addEventListener("ended", () => {
      this.updateIcon(icon, false); // アイコンを再生から停止へ更新
      this.updateCurrentTimeDisplay(audioId, audio.duration); // 最終再生時間を設定
    });
  }

  updateIcon(icon, isPlaying) {
    icon.classList.toggle("fa-play", !isPlaying);
    icon.classList.toggle("fa-pause", isPlaying);
  }

  updateCurrentTimeDisplay(audioId, currentTime) {
    const currentElem = document.getElementById(`current-time-${audioId}`);
    if (currentElem) {
      currentElem.textContent = this.formatTime(currentTime);
    }
  }

  formatTime(time) {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes.toString().padStart(2, "0")}:${seconds
      .toString()
      .padStart(2, "0")}`;
  }
}

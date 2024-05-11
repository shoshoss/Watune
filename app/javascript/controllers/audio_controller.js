import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["playButton"];

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

    // すべての他の音声を停止し、そのアイコンを更新
    document.querySelectorAll("audio").forEach((a) => {
      if (a.id !== `audio-${audioId}` && !a.paused) {
        a.pause();
        this.updateIcon(
          document.getElementById(`audio-icon-${a.id.replace("audio-", "")}`),
          false // 他の音声アイコンを「再生」状態に戻す
        );
      } else if (a.id !== `audio-${audioId}` && a.paused) {
        // 再生されていない他の音声のアイコンも再生状態に戻す
        this.updateIcon(
          document.getElementById(`audio-icon-${a.id.replace("audio-", "")}`),
          false
        );
      }
    });

    // 音声が添付されていない場合はここで処理を終了
    if (!audio) {
      return;
    }

    // 音声の再生状態を切り替える
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

    const icon = document.getElementById(`audio-icon-${audioId}`);
    const seekBar = document.querySelector(`input[data-audio-id="${audioId}"]`);
    audio.addEventListener("timeupdate", () => {
      this.updateCurrentTimeDisplay(audioId, audio.currentTime);
      seekBar.value = audio.currentTime;
    });

    seekBar.addEventListener("input", () => {
      audio.currentTime = seekBar.value;
    });

    audio.addEventListener("ended", () => {
      this.updateCurrentTimeDisplay(audioId, 0);
      seekBar.value = 0;
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

  hoverEffect() {
    this.playButtonTarget.classList.remove("text-blue-500");
    this.playButtonTarget.classList.add("text-sky-400");
  }

  unhoverEffect() {
    this.playButtonTarget.classList.remove("text-sky-400");
    this.playButtonTarget.classList.add("text-blue-500");
  }
}

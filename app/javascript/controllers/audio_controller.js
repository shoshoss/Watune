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
    event.stopPropagation(); // クリックイベントの伝播を停止
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    const icon = document.getElementById(`audio-icon-${audioId}`);
    const seekBar = document.querySelector(`input[data-audio-id="${audioId}"]`);
    const postBody = document.querySelector(`div[data-audio-id="${audioId}"]`);

    // すべての他の音声を停止し、そのアイコンを更新
    document.querySelectorAll("audio").forEach((a) => {
      if (a.id !== `audio-${audioId}` && !a.paused) {
        a.pause();
        this.updateIcon(
          document.getElementById(`audio-icon-${a.id.replace("audio-", "")}`),
          false // 他の音声アイコンを「再生」状態に戻す
        );
        this.updateButtonColor(
          document.querySelector(
            `div[data-audio-id="${a.id.replace("audio-", "")}`
          ),
          false // 他の音声ボタンの色を元に戻す
        );
        this.updateTextColor(
          document.querySelector(
            `div[data-audio-id="${a.id.replace("audio-", "")}`
          ),
          false // 他の投稿文章の色を元に戻す
        );
      } else if (a.id !== `audio-${audioId}` && a.paused) {
        // 再生されていない他の音声のアイコンも再生状態に戻す
        this.updateIcon(
          document.getElementById(`audio-icon-${a.id.replace("audio-", "")}`),
          false
        );
        this.updateButtonColor(
          document.querySelector(
            `div[data-audio-id="${a.id.replace("audio-", "")}`
          ),
          false
        );
        this.updateTextColor(
          document.querySelector(
            `div[data-audio-id="${a.id.replace("audio-", "")}`
          ),
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
          this.updateButtonColor(button, true); // クラスの変更を追加
          this.updateTextColor(postBody, true); // クラスの変更を追加
        })
        .catch((error) => {
          console.error("Playback failed:", error);
          alert(`音声の再生に失敗しました: ${error.message}`);
          this.updateIcon(icon, false);
          this.updateButtonColor(button, false); // クラスの変更を追加
          this.updateTextColor(postBody, false); // クラスの変更を追加
        });
    } else {
      audio.pause();
      this.updateIcon(icon, false);
      this.updateButtonColor(button, false); // クラスの変更を追加
      this.updateTextColor(postBody, false); // クラスの変更を追加
    }

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
      this.updateIcon(icon, false);
      this.updateButtonColor(button, false); // クラスの変更を追加
      this.updateTextColor(postBody, false); // クラスの変更を追加
    });
  }

  seek(event) {
    const seekBar = event.currentTarget;
    const audioId = seekBar.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    if (audio) {
      audio.currentTime = seekBar.value;
    }
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
    this.playButtonTarget.classList.add("text-sky-400-accent");
  }

  unhoverEffect() {
    this.playButtonTarget.classList.remove("text-sky-400-accent");
    this.playButtonTarget.classList.add("text-blue-500");
  }

  updateButtonColor(button, isPlaying) {
    if (isPlaying) {
      button.classList.add("text-sky-400-accent");
      button.classList.remove("text-blue-500");
    } else {
      button.classList.remove("text-sky-400-accent");
      button.classList.add("text-blue-500");
    }
  }

  updateTextColor(postBody, isPlaying) {
    if (isPlaying) {
      postBody.classList.add("text-sky-400-accent");
      postBody.classList.remove("text-blue-500");
    } else {
      postBody.classList.remove("text-sky-400-accent");
      postBody.classList.add("text-blue-500");
    }
  }

  navigateToPost(event) {
    const ignoredElements = [
      ".play-audio-button",
      ".audio-icon",
      'input[type="range"]',
      "a",
      "button",
    ];
    if (ignoredElements.some((selector) => event.target.closest(selector))) {
      return; // クリック対象が無視リストのいずれかに一致する場合は何もしない
    }
    const postBody = event.currentTarget;
    const url = postBody.dataset.url;
    if (url) {
      window.location.href = url;
    }
  }
}

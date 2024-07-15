import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["playButton"];

  connect() {
    this.updateAllIconsToPlay(); // 初期化時に全アイコンを再生ボタンに設定
  }

  // すべての音声アイコンを再生ボタンに設定
  updateAllIconsToPlay() {
    document.querySelectorAll(".audio-icon").forEach((icon) => {
      icon.classList.remove("fa-pause");
      icon.classList.add("fa-play");
    });
  }

  // 再生/一時停止ボタンがクリックされたときの処理
  playPause(event) {
    event.stopPropagation(); // クリックイベントの伝播を停止
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    const icon = document.getElementById(`audio-icon-${audioId}`);
    const seekBar = document.querySelector(`input[data-audio-id="${audioId}"]`);
    const postBody = document.querySelector(`div[data-audio-id="${audioId}"]`);

    this.stopAllOtherAudios(audioId); // 他のすべての音声を停止

    if (!audio) return; // 音声が存在しない場合は処理を終了

    if (audio.paused) {
      audio
        .play()
        .then(() => {
          this.updateIcon(icon, true);
          this.updateButtonColor(button, true);
          this.updateTextColor(audioId, true); // IDを使って更新
        })
        .catch((error) => {
          console.error("Playback failed:", error);
          alert(`音声の再生に失敗しました: ${error.message}`);
          this.updateIcon(icon, false);
          this.updateButtonColor(button, false);
          this.updateTextColor(audioId, false); // IDを使って更新
        });
    } else {
      audio.pause();
      this.updateIcon(icon, false);
      this.updateButtonColor(button, false);
      this.updateTextColor(audioId, false); // IDを使って更新
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
      this.updateButtonColor(button, false);
      this.updateTextColor(audioId, false); // IDを使って更新
    });
  }

  // シークバーの位置を変更したときの処理
  seek(event) {
    const seekBar = event.currentTarget;
    const audioId = seekBar.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    if (audio) {
      audio.currentTime = seekBar.value;
    }
  }

  // アイコンの状態を更新
  updateIcon(icon, isPlaying) {
    icon.classList.toggle("fa-play", !isPlaying);
    icon.classList.toggle("fa-pause", isPlaying);
  }

  // 現在の再生時間を表示
  updateCurrentTimeDisplay(audioId, currentTime) {
    const currentElem = document.getElementById(`current-time-${audioId}`);
    if (currentElem) {
      currentElem.textContent = this.formatTime(currentTime);
    }
  }

  // 再生時間をフォーマット
  formatTime(time) {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes.toString().padStart(2, "0")}:${seconds
      .toString()
      .padStart(2, "0")}`;
  }

  // ホバー時の色変更
  hoverEffect() {
    this.playButtonTarget.classList.remove("text-blue-500");
    this.playButtonTarget.classList.add("text-sky-400-accent");
  }

  // ホバー解除時の色変更
  unhoverEffect() {
    this.playButtonTarget.classList.remove("text-sky-400-accent");
    this.playButtonTarget.classList.add("text-blue-500");
  }

  // ボタンの色を更新
  updateButtonColor(element, isPlaying) {
    if (isPlaying) {
      element.classList.add("text-sky-400-accent");
      element.classList.remove("text-blue-500");
    } else {
      element.classList.remove("text-sky-400-accent");
      element.classList.add("text-blue-500");
    }
  }

  // テキストとアイコンの色を更新
  updateTextColor(audioId, isPlaying) {
    const postBody = document.querySelector(`div[data-audio-id="${audioId}"]`);
    if (postBody) {
      if (isPlaying) {
        postBody.classList.add("text-sky-400-accent");
        postBody.classList.remove("text-blue-500");
      } else {
        postBody.classList.remove("text-sky-400-accent");
        postBody.classList.add("text-blue-500");
      }
    }

    const xIcon = document.querySelector(`#x-icon-${audioId}`);
    if (xIcon) {
      if (isPlaying) {
        xIcon.classList.add("text-sky-400-accent");
        xIcon.classList.remove("text-black-500");
      } else {
        xIcon.classList.remove("text-sky-400-accent");
        xIcon.classList.add("text-black-500");
      }
    }
  }

  // 投稿をクリックしたときの処理
  navigateToPost(event) {
    const ignoredElements = [
      ".play-audio-button",
      ".audio-icon",
      'input[type="range"]',
      "a",
      "button",
      "audio",
    ];
    if (ignoredElements.some((selector) => event.target.closest(selector))) {
      return; // クリック対象が無視リストのいずれかに一致する場合は何もしない
    }

    const postBody = event.currentTarget;
    const url = postBody.dataset.url;
    const audioId = postBody.dataset.postId;

    console.log("navigateToPost", { url, audioId }); // デバッグ用ログ

    if (!url) {
      this.toggleAudioPlayback(audioId, postBody);
    } else {
      Turbo.visit(url); // Turboを使用して遷移
    }
  }

  // 他のすべての音声を停止
  stopAllOtherAudios(currentAudioId) {
    document
      .querySelectorAll(`audio:not(#audio-${currentAudioId})`)
      .forEach((audio) => {
        if (!audio.paused) {
          audio.pause();
          const audioId = audio.id.replace("audio-", "");
          this.updateIcon(
            document.getElementById(`audio-icon-${audioId}`),
            false
          );
          this.updateButtonColor(
            document.querySelector(`button[data-audio-id="${audioId}"]`),
            false
          );
          this.updateTextColor(audioId, false);
        }
      });
  }

  // 音声の再生/一時停止を切り替える
  toggleAudioPlayback(audioId, postBody) {
    const audioElement = document.getElementById(`audio-${audioId}`);
    if (audioElement) {
      this.stopAllOtherAudios(audioId);

      if (audioElement.paused) {
        audioElement
          .play()
          .then(() => {
            this.updateIcon(
              document.getElementById(`audio-icon-${audioId}`),
              true
            );
            this.updateButtonColor(
              postBody.querySelector(`button[data-audio-id="${audioId}"]`),
              true
            );
            this.updateTextColor(audioId, true); // IDを使って更新
          })
          .catch((error) => {
            console.error("Playback failed:", error);
            alert(`音声の再生に失敗しました: ${error.message}`);
            this.updateIcon(
              document.getElementById(`audio-icon-${audioId}`),
              false
            );
            this.updateButtonColor(
              postBody.querySelector(`button[data-audio-id="${audioId}"]`),
              false
            );
            this.updateTextColor(audioId, false); // IDを使って更新
          });
      } else {
        audioElement.pause();
        this.updateIcon(
          document.getElementById(`audio-icon-${audioId}`),
          false
        );
        this.updateButtonColor(
          postBody.querySelector(`button[data-audio-id="${audioId}"]`),
          false
        );
        this.updateTextColor(audioId, false); // IDを使って更新
      }
    }
  }
}

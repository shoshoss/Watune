import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["audio"];
  lastPlayedAudio = null; // 最後に再生されたオーディオを記録

  connect() {
    this.element.addEventListener(
      "play",
      (event) => {
        // 直前に再生していた音声を停止
        if (this.lastPlayedAudio && this.lastPlayedAudio !== event.target) {
          this.lastPlayedAudio.pause();
          this.updateIconForAudio(this.lastPlayedAudio, false);
        }
        this.lastPlayedAudio = event.target; // 再生したオーディオを更新
      },
      true
    );
  }

  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = this.element.querySelector(`audio[id="audio-${audioId}"]`);

    if (!audio) {
      console.error(`Audio element with ID 'audio-${audioId}' not found.`);
      return;
    }

    if (audio.paused) {
      audio
        .play()
        .then(() => {
          this.updateIcon(button, true);
        })
        .catch((error) => {
          console.error("Playback failed:", error);
          alert(`音声の再生に失敗しました: ${error.message}`);
          this.updateIcon(button, false);
        });
    } else {
      audio.pause();
      this.updateIcon(button, false);
    }
  }

  updateIconForAudio(audio, isPlaying) {
    const audioId = audio.id.replace("audio-", "");
    const button = this.element.querySelector(
      `button[data-audio-id="${audioId}"]`
    );
    this.updateIcon(button, isPlaying);
  }

  updateIcon(button, isPlaying) {
    if (button) {
      button.classList.toggle("fa-play", !isPlaying);
      button.classList.toggle("fa-pause", isPlaying);
    }
  }
}

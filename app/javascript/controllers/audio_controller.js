import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}

  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    const icon = document.getElementById(`audio-icon-${audioId}`);

    // 再生中のすべての音声を停止する（現在のオーディオを除く）
    const audios = document.querySelectorAll("audio");
    audios.forEach((a) => {
      if (a !== audio && !a.paused) {
        a.pause();
        this.updateIconForAudio(a, false);
      }
    });

    // 対象のaudioがある場合、再生状態を切り替える
    if (audio && icon) {
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
    }
  }

  updateIconForAudio(audio, isPlaying) {
    const audioId = audio.id.replace("audio-", "");
    const icon = document.getElementById(`audio-icon-${audioId}`);
    this.updateIcon(icon, isPlaying);
  }

  updateIcon(icon, isPlaying) {
    if (icon) {
      icon.classList.toggle("fa-play", !isPlaying);
      icon.classList.toggle("fa-pause", isPlaying);
    }
  }
}

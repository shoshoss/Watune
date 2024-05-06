import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener(
      "play",
      (event) => {
        const audios = document.querySelectorAll("audio");
        for (let audio of audios) {
          if (audio !== event.target) {
            audio.pause();
            this.updateIconForAudio(audio, false);
          }
        }
      },
      true
    );
  }

  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.getElementById(`audio-${audioId}`);
    const icon = document.getElementById(`audio-icon-${audioId}`);

    if (!audio || !icon) {
      console.error(
        `Audio element with ID 'audio-${audioId}' or icon element with ID 'audio-icon-${audioId}' not found.`
      );
      return;
    }

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

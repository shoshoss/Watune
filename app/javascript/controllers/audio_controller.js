import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener(
      "play",
      (event) => {
        const audios = document.querySelectorAll("audio");
        audios.forEach((audio) => {
          if (audio !== event.target) {
            audio.pause();
            this.updateIconForAudio(audio, false);
          }
        });
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
          this.updateIcon(button, false);
        });
    } else {
      audio.pause();
      this.updateIcon(button, false);
    }
  }

  updateIconForAudio(audio, isPlaying) {
    const audioId = audio.id.replace("audio-", "");
    const button = this.element.querySelector(`[data-audio-id="${audioId}"]`);
    console.log(`Update icon for audio ID: ${audioId}, Button found:`, button);
    this.updateIcon(button, isPlaying);
  }

  updateIcon(button, isPlaying) {
    if (button) {
      button.classList.toggle("fa-play", !isPlaying);
      button.classList.toggle("fa-pause", isPlaying);
    } else {
      console.error("Button element not found for updateIcon.");
    }
  }
}

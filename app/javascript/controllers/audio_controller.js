import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    const audio = document.querySelector(`audio[id="audio-${audioId}"]`);

    if (!audio) {
      console.error("Audio element not found!");
      return;
    }

    if (audio.paused) {
      audio
        .play()
        .then(() => {
          button.classList.remove("fa-play");
          button.classList.add("fa-pause");
        })
        .catch((error) => {
          console.error("Playback failed:", error);
        });
    } else {
      audio.pause();
      button.classList.remove("fa-pause");
      button.classList.add("fa-play");
    }
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  audioCtx;
  canvasCtx;
  mediaRecorder;
  chunks = [];
  animationFrameRequest;

  connect() {
    this.element.setAttribute("open", true); // モーダルを開く処理

    this.canvasCtx = this.element.querySelector(".visualizer").getContext("2d");
    if (!this.audioCtx) {
      this.audioCtx = new AudioContext();
    }
  }

  closeModal() {
    this.element.close(); // モーダルを閉じる
  }

  startRecording() {
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        this.mediaRecorder = new MediaRecorder(stream);
        this.mediaRecorder.ondataavailable = (event) =>
          this.chunks.push(event.data);
        this.mediaRecorder.onstop = () => this.handleRecordingStop();
        this.mediaRecorder.start();

        this.element.querySelector(".record").disabled = true;
        this.element.querySelector(".stop").disabled = false;

        this.visualize(stream);
      })
      .catch((error) =>
        console.error("Error accessing the microphone:", error)
      );
  }

  stopRecording() {
    this.mediaRecorder.stop();
    this.element.querySelector(".record").disabled = false;
    this.element.querySelector(".stop").disabled = true;
    this.shouldStop = true;
    cancelAnimationFrame(this.animationFrameRequest);
  }

  handleRecordingStop() {
    const audioURL = window.URL.createObjectURL(new Blob(this.chunks));
    this.createSoundClip(audioURL);
    this.chunks = []; // Clear the chunks array
  }

  createSoundClip(audioURL) {
    const clipContainer = document.createElement("article");
    const audio = document.createElement("audio");
    const deleteButton = document.createElement("button");
    const clipLabel = document.createElement("label");

    clipLabel.textContent =
      prompt("Enter a name for your sound clip?", "My unnamed clip") ||
      "My unnamed clip";
    deleteButton.textContent = "Delete";
    deleteButton.className = "delete";
    audio.src = audioURL;
    audio.controls = true;

    clipContainer.classList.add("clip");
    clipContainer.appendChild(audio);
    clipContainer.appendChild(clipLabel);
    clipContainer.appendChild(deleteButton);
    this.element.querySelector(".sound-clips").appendChild(clipContainer);

    deleteButton.onclick = () => clipContainer.remove();
  }

  visualize(stream) {
    const source = this.audioCtx.createMediaStreamSource(stream);
    const analyser = this.audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    source.connect(analyser);

    const draw = () => {
      if (this.shouldStop) return;
      this.animationFrameRequest = requestAnimationFrame(draw);
      analyser.getByteTimeDomainData(dataArray);

      const WIDTH = this.canvasCtx.canvas.width;
      const HEIGHT = this.canvasCtx.canvas.height;

      this.canvasCtx.fillStyle = "rgb(200, 200, 200)";
      this.canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
      this.canvasCtx.lineWidth = 2;
      this.canvasCtx.strokeStyle = "rgb(0, 0, 0)";
      this.canvasCtx.beginPath();

      let x = 0;
      for (let i = 0; i < bufferLength; i++) {
        const v = dataArray[i] / 128.0;
        const y = (v * HEIGHT) / 2;

        if (i === 0) {
          this.canvasCtx.moveTo(x, y);
        } else {
          this.canvasCtx.lineTo(x, y);
        }
        x += WIDTH / bufferLength;
      }

      this.canvasCtx.lineTo(WIDTH, HEIGHT / 2);
      this.canvasCtx.stroke();
    };

    draw();
  }
}

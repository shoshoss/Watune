import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  audioCtx;
  canvasCtx;
  mediaRecorder;
  shouldStop = false;
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
        // MIMEタイプの指定を省略してデフォルトのフォーマットを使用
        this.mediaRecorder = new MediaRecorder(stream);
        let chunks = [];

        this.element.querySelector(".record").disabled = true;
        this.element.querySelector(".stop").disabled = false;
        this.shouldStop = false;

        this.mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
        this.mediaRecorder.onstop = (e) => this.handleRecordingStop(chunks);
        this.mediaRecorder.start();

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

  handleRecordingStop(chunks) {
    const blob = new Blob(chunks, { type: this.mediaRecorder.mimeType });
    const audioURL = window.URL.createObjectURL(blob);
    this.createSoundClip(audioURL);
  }

  createSoundClip(audioURL) {
    const clipContainer = document.createElement("article");
    const audio = document.createElement("audio");
    const deleteButton = document.createElement("button");

    clipContainer.classList.add("clip");
    audio.setAttribute("controls", "");
    audio.src = audioURL;
    deleteButton.textContent = "Delete";
    deleteButton.className = "delete";

    clipContainer.appendChild(audio);
    clipContainer.appendChild(deleteButton);
    this.element.querySelector(".sound-clips").appendChild(clipContainer);

    deleteButton.addEventListener("click", (e) => {
      e.target.closest(".clip").remove();
    });
  }

  visualize(stream) {
    const source = this.audioCtx.createMediaStreamSource(stream);
    const analyser = this.audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);

    source.connect(analyser);

    const WIDTH = this.element.querySelector(".visualizer").width;
    const HEIGHT = this.element.querySelector(".visualizer").height;

    const draw = () => {
      if (this.shouldStop) return;
      this.animationFrameRequest = requestAnimationFrame(draw);
      analyser.getByteTimeDomainData(dataArray);

      this.canvasCtx.fillStyle = "rgb(200, 200, 200)";
      this.canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
      this.canvasCtx.lineWidth = 2;
      this.canvasCtx.strokeStyle = "rgb(0, 0, 0)";
      this.canvasCtx.beginPath();

      let sliceWidth = (WIDTH * 1.0) / bufferLength;
      let x = 0;

      for (let i = 0; i < bufferLength; i++) {
        let v = dataArray[i] / 128.0;
        let y = (v * HEIGHT) / 2;

        if (i === 0) {
          this.canvasCtx.moveTo(x, y);
        } else {
          this.canvasCtx.lineTo(x, y);
        }

        x += sliceWidth;
      }

      this.canvasCtx.lineTo(WIDTH, HEIGHT / 2);
      this.canvasCtx.stroke();
    };

    draw();
  }
}

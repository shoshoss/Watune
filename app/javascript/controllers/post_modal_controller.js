import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["record", "stop", "canvas", "soundClips"];
  audioCtx;
  canvasCtx;

  connect() {
    // ボタンクリック時にモーダルを開く処理
    this.element.setAttribute("open", true);
    // モーダルが開いたときにバックグラウンドをクリックして閉じるイベントを追加
    // this.element.addEventListener("click", this.closeBackground.bind(this));

    this.canvasCtx = this.canvasTarget.getContext("2d");
    if (!this.audioCtx) {
      this.audioCtx = new AudioContext();
    }
  }

  closeModal() {
    // モーダルを閉じる
    this.element.close();
  }

  closeBackground(event) {
    // バックグラウンドをクリックしたかどうかをチェック
    if (
      event.target === this.dialogTarget &&
      this.dialogTarget.hasAttribute("open")
    ) {
      console.log("Dialog closed");
      // モーダルを閉じる
      this.closeModal();
    }
  }

  redirectAfterClose(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }
    // リダイレクトパスを取得してリダイレクトを実行する
    const redirectPath = this.data.get("redirectPath");
    window.location.href = redirectPath;
  }

  startRecording() {
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        const mediaRecorder = new MediaRecorder(stream);
        let chunks = [];

        this.recordTarget.disabled = true;
        this.stopTarget.disabled = false;

        mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
        mediaRecorder.onstop = (e) => this.handleRecordingStop(chunks);
        mediaRecorder.start();

        this.visualize(stream);
      })
      .catch((error) => console.log("Error accessing the microphone:", error));
  }

  stopRecording() {
    this.recordTarget.disabled = false;
    this.stopTarget.disabled = true;
    console.log("stopRecording");
  }

  handleRecordingStop(chunks) {
    const blob = new Blob(chunks, { type: "audio/ogg; codecs=opus" });
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
    this.soundClipsTarget.appendChild(clipContainer);

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

    const WIDTH = this.canvasTarget.width;
    const HEIGHT = this.canvasTarget.height;

    const draw = () => {
      requestAnimationFrame(draw);
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

      this.canvasCtx.lineTo(
        this.canvasTarget.width,
        this.canvasTarget.height / 2
      );
      this.canvasCtx.stroke();
    };

    draw();
  }
}

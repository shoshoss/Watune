import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  audioCtx;
  canvasCtx;
  mediaRecorder;
  shouldStop = false;
  animationFrameRequest;
  startTime;
  recordingInterval;

  // 初期設定: コントローラが接続されたときに呼ばれる
  connect() {
    this.element.setAttribute("open", true);

    // モーダルが開いたときにバックグラウンドをクリックして閉じるイベントを追加
    // this.element.addEventListener("click", this.closeBackground.bind(this));
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

  afterClose(event) {
    if (!event.detail.success) {
      // フォームのバリデーションエラーの場合はここで何もしない
      return;
    }

    Turbo.visit(window.location.href, { action: "replace" });
  }

  // 録音開始
  startRecording() {
    const canvas = this.element.querySelector(".visualizer");
    if (!canvas) {
      console.error("Canvas要素が見つかりませんでした！");
      return;
    }

    this.canvasCtx = canvas.getContext("2d");
    if (!this.audioCtx) {
      this.audioCtx = new AudioContext();
    }

    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        this.mediaRecorder = new MediaRecorder(stream);
        let chunks = [];

        this.element.querySelector(".record").disabled = true;
        this.element.querySelector(".stop").disabled = false;
        this.element.querySelector('input[type="submit"]').disabled = true; // Submitボタンを無効化
        this.shouldStop = false;
        this.startTime = Date.now();
        this.recordingInterval = setInterval(() => this.updateTimer(), 1000);

        this.mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
        this.mediaRecorder.onstop = (e) => this.handleRecordingStop(chunks);
        this.mediaRecorder.start();

        // 録音時間の制限を設定 (例: 30秒)
        setTimeout(() => {
          if (!this.shouldStop) this.stopRecording();
        }, 30000); // 30秒後に自動停止

        this.visualize(stream);
      })
      .catch((error) => {
        console.error("マイクへのアクセス中にエラーが発生しました:", error);
      });
  }

  // 録音を停止するメソッド
  stopRecording() {
    this.mediaRecorder.stop();
    clearInterval(this.recordingInterval);
    this.element.querySelector(".stop").disabled = true;
    this.shouldStop = true;
    cancelAnimationFrame(this.animationFrameRequest);

    // 経過時間をミリ秒から秒に変換し、切り捨てを行う
    const durationInSeconds = Math.floor((Date.now() - this.startTime) / 1000);
    document.querySelector(".duration-field").value = durationInSeconds;
  }

  // タイマー更新
  updateTimer() {
    const elapsedTime = Date.now() - this.startTime;
    const seconds = Math.floor((elapsedTime / 1000) % 60);
    const minutes = Math.floor(elapsedTime / 1000 / 60);
    this.element.querySelector(".timer").textContent = `${this.pad(
      minutes
    )}:${this.pad(seconds)}`;
  }

  // 数字を2桁に整形するメソッド
  pad(number) {
    return number < 10 ? "0" + number : number;
  }

  // 録音停止後の処理
  handleRecordingStop(chunks) {
    const blob = new Blob(chunks, { type: this.mediaRecorder.mimeType });
    const audioURL = window.URL.createObjectURL(blob);
    this.createSoundClip(audioURL);

    // MIMEタイプから適切なファイル拡張子を決定
    const fileExtension =
      this.mediaRecorder.mimeType.split("/")[1].split(";")[0] === "webm"
        ? "webm"
        : "mp4";

    const file = new File([blob], `recording.${fileExtension}`, {
      type: this.mediaRecorder.mimeType,
    });

    const dt = new DataTransfer();
    dt.items.add(file);
    const fileInput = document.querySelector('input[type="file"]');
    fileInput.files = dt.files;

    // Submitボタンを有効化
    const submitButton = fileInput.form.querySelector('input[type="submit"]');
    submitButton.disabled = false;
  }

  // 音声クリップを生成して表示するメソッド
  createSoundClip(audioURL) {
    const clipContainer = document.createElement("div");
    clipContainer.className =
      "clip flex flex-col items-center w-full max-w-screen-lg mx-auto my-2 p-2 border border-gray-200 rounded overflow-hidden";

    const audio = document.createElement("audio");
    audio.controls = true;
    audio.src = audioURL;
    audio.className = "w-full";

    // 削除ボタン
    const deleteButton = this.createDeleteButton(clipContainer);

    clipContainer.appendChild(audio);
    clipContainer.appendChild(deleteButton);

    this.element.querySelector(".sound-clips").innerHTML = "";
    this.element.querySelector(".sound-clips").appendChild(clipContainer);
  }

  // 削除ボタンを生成するメソッド
  createDeleteButton(clipContainer) {
    const deleteButton = document.createElement("button");
    deleteButton.textContent = "削除";
    deleteButton.className =
      "bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded mt-2 self-end"; // 右端に配置
    deleteButton.onclick = () => {
      clipContainer.remove();
      this.element.querySelector(".record").disabled = false;
      this.element.querySelector(".timer").textContent = "00:00"; // タイマーをリセット
    };

    return deleteButton;
  }

  // 可視化処理
  visualize(stream) {
    const source = this.audioCtx.createMediaStreamSource(stream);
    const analyser = this.audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);

    source.connect(analyser);
    analyser.smoothingTimeConstant = 0.9; // スムージングを適用

    const visualizerElement = this.element.querySelector(".visualizer");
    const WIDTH = visualizerElement.width;
    const HEIGHT = visualizerElement.height;
    const centerX = WIDTH / 2;
    const centerY = HEIGHT / 2;

    const draw = () => {
      if (this.shouldStop) return;
      this.animationFrameRequest = requestAnimationFrame(draw);

      analyser.getByteFrequencyData(dataArray); // 周波数データを取得

      this.canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);

      let maxRadius = Math.max(WIDTH, HEIGHT) / 2;
      let step = (maxRadius / bufferLength) * 2;

      for (let i = 0; i < bufferLength; i++) {
        let radius = step * i;
        let amplitude = dataArray[i] / 128.0; // 初期256
        let color = `hsla(${200 + amplitude * 20}, 100%, 50%, ${
          0.75 + 0.25 * amplitude // 透明度を動的に変更 初期:0.5,0.5
        })`; // 波紋の色をより海色に近づける

        this.canvasCtx.beginPath();
        this.canvasCtx.arc(centerX, centerY, radius, 0, Math.PI * 2);
        this.canvasCtx.strokeStyle = color;
        this.canvasCtx.lineWidth = 2;
        this.canvasCtx.stroke();
      }
    };

    draw();
  }
}

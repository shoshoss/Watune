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

    this.canvasCtx = this.element.querySelector(".visualizer").getContext("2d");
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

  // 録音開始
  startRecording() {
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        this.mediaRecorder = new MediaRecorder(stream);
        let chunks = [];

        this.element.querySelector(".record").disabled = true;
        this.element.querySelector(".stop").disabled = false;
        this.shouldStop = false;
        this.startTime = Date.now();
        this.recordingInterval = setInterval(() => this.updateTimer(), 1000);

        this.mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
        this.mediaRecorder.onstop = (e) => this.handleRecordingStop(chunks);
        this.mediaRecorder.start();

        this.visualize(stream);
      })
      .catch((error) => {
        console.error("マイクへのアクセス中にエラーが発生しました:", error);
      });
  }

  // 録音停止
  stopRecording() {
    this.mediaRecorder.stop();
    clearInterval(this.recordingInterval);
    this.element.querySelector(".stop").disabled = true;
    this.shouldStop = true;
    cancelAnimationFrame(this.animationFrameRequest);
  }

  // タイマーを更新
  updateTimer() {
    const elapsedTime = Date.now() - this.startTime;
    const seconds = Math.floor((elapsedTime / 1000) % 60);
    const minutes = Math.floor(elapsedTime / 1000 / 60);
    this.element.querySelector(".timer").textContent = `${this.pad(
      minutes
    )}:${this.pad(seconds)}`;
  }

  // 数字を2桁に整形
  pad(number) {
    return number < 10 ? "0" + number : number;
  }

  // 録音停止後の処理
  handleRecordingStop(chunks) {
    const blob = new Blob(chunks, { type: this.mediaRecorder.mimeType });
    const audioURL = window.URL.createObjectURL(blob);
    this.createSoundClip(audioURL);
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

    const WIDTH = this.element.querySelector(".visualizer").width;
    const HEIGHT = this.element.querySelector(".visualizer").height;

    const draw = () => {
      if (this.shouldStop) return;
      this.animationFrameRequest = requestAnimationFrame(draw);
      analyser.getByteTimeDomainData(dataArray);

      this.canvasCtx.fillStyle = "rgb(200, 200, 200)";
      this.canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
      this.canvasCtx.beginPath();

      let sliceWidth = WIDTH / bufferLength;
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

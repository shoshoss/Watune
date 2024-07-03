import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  audioCtx;
  canvasCtx;
  mediaRecorder;
  shouldStop = false;
  animationFrameRequest;
  startTime;
  recordingInterval;

  // 初期設定 コントローラが接続されたときに呼ばれる
  connect() {
    this.checkForm(); // フォームの初期状態をチェック
  }

  // フォームの状態をチェックし、投稿ボタンの有効/無効を切り替えるメソッド
  checkForm() {
    const textArea = this.element.querySelector("#body");
    const hasText = textArea && textArea.value.trim().length > 0;
    const soundClips = this.element.querySelector(".sound-clips");
    const hasAudio = soundClips.querySelector("audio") !== null;

    const submitButton = this.element.querySelector('input[type="submit"]');
    if (hasText || hasAudio) {
      submitButton.disabled = false;
      submitButton.classList.remove("opacity-50");
      submitButton.classList.remove("cursor-not-allowed");
    } else {
      submitButton.disabled = true;
      submitButton.classList.add("opacity-50");
      submitButton.classList.add("cursor-not-allowed");
    }
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

        // 録音時間の制限を設定 (例: 59分59秒)
        setTimeout(() => {
          if (!this.shouldStop) this.stopRecording();
        }, (59 * 60 + 59) * 1000); // 59分59秒後に自動停止

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
    this.checkForm(); // フォームの状態を再チェック
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
    // 録音データをBlobに変換
    const blob = new Blob(chunks, { type: this.mediaRecorder.mimeType });

    // Blobから生成されたURLを取得
    const audioURL = window.URL.createObjectURL(blob);
    this.previewAudioURL = audioURL; // プレビュー用のオーディオURLを設定
    this.previewAudioType = this.mediaRecorder.mimeType; // プレビュー用のMIMEタイプを設定

    // プレビュー用のサウンドクリップを作成
    this.createSoundClip(audioURL, this.mediaRecorder.mimeType);

    // MIMEタイプからファイル拡張子を決定
    const mimeType = this.mediaRecorder.mimeType;
    const fileExtension = mimeType.split("/")[1].split(";")[0];

    // 録音データをファイルに変換
    const file = new File([blob], `recording.${fileExtension}`, {
      type: mimeType,
    });

    // DataTransferオブジェクトを使用してファイル入力にファイルを設定
    const dt = new DataTransfer();
    dt.items.add(file);
    const fileInput = document.querySelector('input[type="file"]');
    fileInput.files = dt.files;

    // Submitボタンを有効化
    const submitButton = fileInput.form.querySelector('input[type="submit"]');
    submitButton.disabled = false;

    // フォームの状態を再チェック
    this.checkForm();
  }

  // 音声クリップを生成して表示するメソッド
  createSoundClip(audioURL, mimeType) {
    const clipContainer = document.createElement("div");
    clipContainer.className =
      "clip flex flex-col items-center w-full max-w-screen-lg mx-auto my-2 p-2 border border-gray-200 rounded overflow-hidden";

    const audio = document.createElement("audio");
    audio.controls = true;
    audio.src = audioURL;
    audio.type = mimeType;
    audio.className = "w-full";

    // 削除ボタンを作成
    const deleteButton = this.createDeleteButton(clipContainer);

    // クリップコンテナにオーディオと削除ボタンを追加
    clipContainer.appendChild(deleteButton);
    clipContainer.appendChild(audio);

    // 既存のサウンドクリップをクリアし、新しいクリップを追加
    this.element.querySelector(".sound-clips").innerHTML = "";
    this.element.querySelector(".sound-clips").appendChild(clipContainer);
  }

  // 削除ボタンを生成するメソッド
  createDeleteButton(clipContainer) {
    const deleteButton = document.createElement("button");
    deleteButton.textContent = "削除";
    deleteButton.className =
      "bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded mb-2 flex justify-center"; // 右端に配置
    deleteButton.onclick = () => {
      clipContainer.remove();
      this.element.querySelector(".record").disabled = false;
      this.element.querySelector(".timer").textContent = "00:00"; // タイマーをリセット
      this.checkForm(); // フォームの状態を再チェック
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

      this.canvasCtx.clearRect(0, 0, WIDTH, HEIGHT); // 画面をクリア

      let maxRadius = Math.max(WIDTH, HEIGHT) / 2;
      let step = (maxRadius / bufferLength) * 2;

      for (let i = 0; i < bufferLength; i++) {
        let radius = step * i;
        let amplitude = dataArray[i] / 256.0; // 振幅を0-1に正規化

        // 振幅に応じて青色の明るさを調整 (大きいほど明るく)
        let hue = 200; // 固定の青色
        let lightness = 50 + amplitude * 50; // 振幅に応じて明るさを調整 (50% - 100%)
        let color = `hsl(${hue}, 100%, ${lightness}%)`; // 青色の明るさを調整

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

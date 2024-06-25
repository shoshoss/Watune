import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // 初期設定: ボタンのイベントリスナーを設定
  connect() {
    console.log("Controller connected"); // 接続確認のためのログ
    this.recordButton = document.getElementById("recordButton");
    this.stopButton = document.getElementById("stopButton");
    this.audioPlayer = document.getElementById("audioPlayer");

    this.recordButton.addEventListener("click", this.startRecording.bind(this));
    this.stopButton.addEventListener("click", this.stopRecording.bind(this));

    this.stopButton.style.display = "none"; // 初期状態では停止ボタンを非表示
  }

  // 録音を開始するメソッド
  startRecording() {
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        this.localStream = stream;
        this.mediaRecorder = new MediaRecorder(stream);
        this.mediaRecorder.start();
        console.log("Status: " + this.mediaRecorder.state);

        // ボタンの表示状態を切り替え
        this.recordButton.style.display = "none";
        this.stopButton.style.display = "block";

        this.mediaRecorder.ondataavailable = (event) => {
          this.audioPlayer.src = window.URL.createObjectURL(event.data);
        };
      })
      .catch((err) => {
        console.error("Error accessing media devices.", err);
      });
  }

  // 録音を停止するメソッド
  stopRecording() {
    this.mediaRecorder.stop();
    console.log("Status: " + this.mediaRecorder.state);

    // ボタンの表示状態を元に戻す
    this.recordButton.style.display = "block";
    this.stopButton.style.display = "none";

    // ストリームを停止
    this.localStream.getTracks().forEach((track) => track.stop());
  }
}

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async connect() {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      this.recorder = new MediaRecorder(stream);
      this.recorder.ondataavailable = (event) => {
        const audioBlob = new Blob([event.data], { type: "audio/wav" });
        const audioUrl = URL.createObjectURL(audioBlob);
        this.element.querySelector("audio").src = audioUrl;
      };
    } catch (error) {
      console.error("Error accessing the microphone: ", error);
    }
  }

  startRecording() {
    this.recorder.start();
    console.log("録音を開始しました。");
  }

  stopRecording() {
    this.recorder.stop();
    console.log("録音を停止しました。");
  }
}

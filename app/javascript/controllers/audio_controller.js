import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // オーディオ要素で"play"イベントが発生した際の処理を追加
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

  // 再生/一時停止ボタンがクリックされたときの処理
  playPause(event) {
    const button = event.currentTarget;
    const audioId = button.dataset.audioId;
    // クリックされたボタンに対応するオーディオ要素を取得
    const audio = this.element.querySelector(`audio[id="audio-${audioId}"]`);

    // オーディオ要素が存在しない場合はエラーを出力して処理を終了
    if (!audio) {
      console.error(`Audio element with ID 'audio-${audioId}' not found.`);
      return;
    }

    // オーディオの再生状態に応じて再生/一時停止を切り替え
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

  // オーディオ要素の再生状態に応じてボタンのアイコンを更新
  updateIconForAudio(audio, isPlaying) {
    const audioId = audio.id.replace("audio-", "");
    // 対応するボタン要素を取得
    const button = this.element.querySelector(`[data-audio-id="${audioId}"]`);
    console.log(
      `オーディオID ${audioId} のアイコンを更新します。ボタンが見つかりましたか？`,
      button
    );
    // ボタンのアイコンを更新
    this.updateIcon(button, isPlaying);
  }

  // ボタンのアイコンを更新するメソッド
  updateIcon(button, isPlaying) {
    if (button) {
      // 再生状態に応じてアイコンのクラスを切り替える
      button.classList.toggle("fa-play", !isPlaying);
      button.classList.toggle("fa-pause", isPlaying);
    } else {
      console.error("updateIcon: ボタン要素が見つかりませんでした。");
    }
  }
}

// app/javascript/controllers/widget_history_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    window.addEventListener("popstate", this.handlePopState.bind(this));
  }

  navigate(event) {
    event.preventDefault();
    const url = new URL(event.currentTarget.href);

    // Turboフレームでの遷移
    document.querySelector("#main-content").src = url.pathname;

    // URLを変更し、履歴に追加
    history.pushState({ url: url.pathname }, "", url.pathname);
  }

  handlePopState(event) {
    const state = event.state;
    if (state && state.url) {
      // Turboフレームでの遷移
      document.querySelector("#main-content").src = state.url;
    }
  }
}

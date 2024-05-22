import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.setAttribute("open", true);
  }

  closeModal() {
    this.element.close();
  }

  afterClose(event) {
    if (!event.detail.success) {
      return;
    }

    Turbo.visit(window.location.href, { action: "replace" });
  }

  redirectLink() {
    const redirectPath = this.data.get("redirectPath");
    Turbo.visit(redirectPath, { action: "replace" });
  }
}

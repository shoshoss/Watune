// app/javascript/controllers/category_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link", "posts"];

  connect() {
    this.loadCategory(this.defaultCategory);
    this.setActiveLink(this.defaultLink);
  }

  switch(event) {
    event.preventDefault();
    const category = event.target.dataset.category;
    this.loadCategory(category);
    this.setActiveLink(event.target);
  }

  loadCategory(category) {
    const url = `/profiles?category=${category}`;
    fetch(url, {
      headers: { Accept: "text/vnd.turbo-stream.html" },
    })
      .then((response) => response.text())
      .then((html) => {
        this.postsTarget.innerHTML = html;
      });
  }

  setActiveLink(selectedLink) {
    this.linkTargets.forEach((link) => {
      link.classList.remove("tab-active");
    });
    selectedLink.classList.add("tab-active");
  }

  get defaultCategory() {
    return this.data.get("defaultCategory") || "self";
  }

  get defaultLink() {
    return this.linkTargets.find(
      (link) => link.dataset.category === this.defaultCategory
    );
  }
}

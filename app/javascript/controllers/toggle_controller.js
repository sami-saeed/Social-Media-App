import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section","replySection", "viewSection"]

  toggle() {
    debugger;
    this.sectionTarget.classList.toggle("d-none")
  }

  toggleReply() {
    this.replySectionTarget.classList.toggle("d-none")
  }

  toggleView() {
    this.viewSectionTarget.classList.toggle("d-none")
  }

  connect() {
    console.log("✅ ToggleController connected")
  }
}

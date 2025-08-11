import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "bell"]

  connect() {
    // Close the list on outside clicks
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggle(event) {
    event.preventDefault()
    const isHidden = this.listTarget.style.display === "none" || !this.listTarget.style.display
    this.listTarget.style.display = isHidden ? "block" : "none"
    this.bellTarget.setAttribute("aria-expanded", isHidden ? "true" : "false")
  }

  outsideClickHandler = (event) => {
    if (!this.element.contains(event.target)) {
      this.listTarget.style.display = "none"
      this.bellTarget.setAttribute("aria-expanded", "false")
    }
  }
}

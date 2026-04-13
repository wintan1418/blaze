import { Controller } from "@hotwired/stimulus"

// Dismissable flash toast with slide-in animation and auto-hide.
// Usage:
//   <div data-controller="flash" data-flash-timeout-value="5000" class="translate-x-full">
//     <button data-action="click->flash#dismiss">×</button>
//   </div>
export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    // Slide in on next frame so the transition fires
    requestAnimationFrame(() => {
      this.element.classList.remove("translate-x-full", "opacity-0")
      this.element.classList.add("translate-x-0", "opacity-100")
    })

    if (this.timeoutValue > 0) {
      this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
    }
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  dismiss() {
    if (this.timer) clearTimeout(this.timer)
    this.element.classList.remove("translate-x-0", "opacity-100")
    this.element.classList.add("translate-x-full", "opacity-0")
    setTimeout(() => this.element.remove(), 400)
  }
}

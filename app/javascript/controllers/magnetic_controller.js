import { Controller } from "@hotwired/stimulus"

// Pulls a button toward the cursor on hover for a subtle "magnetic" effect.
//   <a data-controller="magnetic" data-magnetic-strength-value="0.35">Button</a>
export default class extends Controller {
  static values = { strength: { type: Number, default: 0.3 } }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.boundMove  = this.onMove.bind(this)
    this.boundLeave = this.onLeave.bind(this)
    this.element.addEventListener("mousemove", this.boundMove)
    this.element.addEventListener("mouseleave", this.boundLeave)
    this.element.style.transition = "transform 250ms ease-out"
    this.element.style.willChange = "transform"
  }

  disconnect() {
    this.element.removeEventListener("mousemove", this.boundMove)
    this.element.removeEventListener("mouseleave", this.boundLeave)
  }

  onMove(e) {
    const rect = this.element.getBoundingClientRect()
    const x = e.clientX - rect.left - rect.width / 2
    const y = e.clientY - rect.top - rect.height / 2
    this.element.style.transform = `translate3d(${x * this.strengthValue}px, ${y * this.strengthValue}px, 0)`
  }

  onLeave() {
    this.element.style.transform = "translate3d(0, 0, 0)"
  }
}

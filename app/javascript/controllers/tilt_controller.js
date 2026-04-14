import { Controller } from "@hotwired/stimulus"

// Tilts an element in 3D based on cursor position.
// Usage: <div data-controller="tilt" data-tilt-max-value="8">...</div>
export default class extends Controller {
  static values = { max: { type: Number, default: 8 } }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.boundMove  = this.onMove.bind(this)
    this.boundLeave = this.onLeave.bind(this)
    this.element.addEventListener("mousemove", this.boundMove)
    this.element.addEventListener("mouseleave", this.boundLeave)
    this.element.style.transition = "transform 300ms ease-out"
    this.element.style.transformStyle = "preserve-3d"
  }

  disconnect() {
    this.element.removeEventListener("mousemove", this.boundMove)
    this.element.removeEventListener("mouseleave", this.boundLeave)
  }

  onMove(e) {
    const rect = this.element.getBoundingClientRect()
    const x = (e.clientX - rect.left) / rect.width
    const y = (e.clientY - rect.top) / rect.height
    const rotateX = (0.5 - y) * this.maxValue
    const rotateY = (x - 0.5) * this.maxValue
    this.element.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.02)`
  }

  onLeave() {
    this.element.style.transform = "perspective(1000px) rotateX(0) rotateY(0) scale(1)"
  }
}

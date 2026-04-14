import { Controller } from "@hotwired/stimulus"

// Applies a subtle vertical parallax to an element as the user scrolls.
//   <div data-controller="parallax" data-parallax-speed-value="0.3">...</div>
export default class extends Controller {
  static values = { speed: { type: Number, default: 0.25 } }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.ticking = false
    this.boundScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.boundScroll, { passive: true })
    this.element.style.willChange = "transform"
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundScroll)
  }

  onScroll() {
    if (this.ticking) return
    this.ticking = true
    requestAnimationFrame(() => {
      const rect = this.element.getBoundingClientRect()
      if (rect.bottom >= 0 && rect.top <= window.innerHeight) {
        const offset = (window.innerHeight - rect.top) * this.speedValue * -0.1
        this.element.style.transform = `translate3d(0, ${offset}px, 0)`
      }
      this.ticking = false
    })
  }
}

import { Controller } from "@hotwired/stimulus"

// Animates a numeric element from 0 to its final value when it scrolls into
// view. The final value is read from data-count-up-to-value or from the
// element's initial text content.
//
//   <p data-controller="count-up" data-count-up-to-value="26">0</p>
export default class extends Controller {
  static values = {
    to:       { type: Number, default: 0 },
    duration: { type: Number, default: 1400 },
    prefix:   { type: String, default: "" },
    suffix:   { type: String, default: "" }
  }

  connect() {
    // Fall back to parsing the text if `to` isn't provided.
    if (!this.toValue) {
      const n = parseInt(this.element.textContent.replace(/[^\d]/g, ""), 10)
      if (!Number.isNaN(n)) this.toValue = n
    }
    this.element.textContent = `${this.prefixValue}0${this.suffixValue}`

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.render(this.toValue)
      return
    }

    if (!("IntersectionObserver" in window)) {
      this.animate()
      return
    }

    this.io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          this.animate()
          this.io.unobserve(this.element)
        }
      })
    }, { threshold: 0.4 })
    this.io.observe(this.element)
  }

  disconnect() {
    this.io?.disconnect()
  }

  animate() {
    const start = performance.now()
    const from = 0
    const to = this.toValue
    const duration = this.durationValue

    const step = (now) => {
      const elapsed = now - start
      const progress = Math.min(elapsed / duration, 1)
      // easeOutExpo
      const eased = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress)
      this.render(Math.round(from + (to - from) * eased))
      if (progress < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }

  render(value) {
    this.element.textContent = `${this.prefixValue}${value.toLocaleString()}${this.suffixValue}`
  }
}

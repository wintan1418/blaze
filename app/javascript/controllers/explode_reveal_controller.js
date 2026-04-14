import { Controller } from "@hotwired/stimulus"

// Triggers a staggered "explosion" reveal on children marked as explode targets.
// Each target starts collapsed (scale 0.3, rotated, opacity 0) and bursts to
// its natural position with a bouncy ease.
//
// Usage:
//   <div data-controller="explode-reveal"
//        data-explode-reveal-stagger-value="120"
//        data-explode-reveal-duration-value="900">
//     <div data-explode-reveal-target="item">Card 1</div>
//     <div data-explode-reveal-target="item">Card 2</div>
//   </div>
export default class extends Controller {
  static targets = ["item"]
  static values  = {
    stagger:  { type: Number, default: 120 },
    duration: { type: Number, default: 900 },
    threshold:{ type: Number, default: 0.2 }
  }

  connect() {
    // Reduced motion → just show everything
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.itemTargets.forEach((el) => { el.style.opacity = "1" })
      return
    }

    // Collapse state
    this.itemTargets.forEach((el, i) => {
      const rotate = (i % 2 === 0 ? -1 : 1) * (6 + Math.random() * 6)
      el.style.opacity = "0"
      el.style.transform = `translate3d(0, 60px, 0) scale(0.4) rotate(${rotate}deg)`
      el.style.transformOrigin = "center bottom"
      el.style.transition =
        `opacity ${this.durationValue}ms cubic-bezier(0.16, 1, 0.3, 1), ` +
        `transform ${this.durationValue}ms cubic-bezier(0.34, 1.56, 0.64, 1)`
      el.style.willChange = "transform, opacity"
    })

    if (!("IntersectionObserver" in window)) {
      this.explode()
      return
    }

    this.io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          this.explode()
          this.io.disconnect()
        }
      })
    }, { threshold: this.thresholdValue, rootMargin: "0px 0px -40px 0px" })

    this.io.observe(this.element)
  }

  disconnect() {
    this.io?.disconnect()
  }

  explode() {
    this.itemTargets.forEach((el, i) => {
      setTimeout(() => {
        el.style.opacity = "1"
        el.style.transform = "translate3d(0, 0, 0) scale(1) rotate(0)"
      }, i * this.staggerValue)
    })

    // After the last item finishes, fire a burst spark overlay
    const totalDelay = this.itemTargets.length * this.staggerValue + this.durationValue
    setTimeout(() => this.itemTargets.forEach((el) => {
      el.style.willChange = "auto"
    }), totalDelay)
  }
}

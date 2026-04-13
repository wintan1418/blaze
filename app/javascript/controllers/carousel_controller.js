import { Controller } from "@hotwired/stimulus"

// Fade-crossing hero carousel with auto-advance and dot navigation.
// Usage:
//   <div data-controller="carousel" data-carousel-interval-value="5500">
//     <div data-carousel-target="slide" class="absolute inset-0 opacity-100">...</div>
//     <div data-carousel-target="slide" class="absolute inset-0 opacity-0">...</div>
//     <button data-carousel-target="dot" data-action="click->carousel#goto" data-index="0"></button>
//   </div>
export default class extends Controller {
  static targets = ["slide", "dot"]
  static values = { interval: { type: Number, default: 5500 } }

  connect() {
    this.index = 0
    this.render()
    const prefersReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    if (!prefersReduced && this.slideTargets.length > 1) {
      this.timer = setInterval(() => this.next(), this.intervalValue)
    }
    this.element.addEventListener("mouseenter", () => this.pause())
    this.element.addEventListener("mouseleave", () => this.resume())
  }

  disconnect() {
    this.pause()
  }

  pause() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  resume() {
    if (!this.timer && this.slideTargets.length > 1) {
      this.timer = setInterval(() => this.next(), this.intervalValue)
    }
  }

  next() {
    this.index = (this.index + 1) % this.slideTargets.length
    this.render()
  }

  goto(event) {
    const i = parseInt(event.currentTarget.dataset.index, 10)
    if (!Number.isNaN(i)) {
      this.index = i
      this.render()
      this.pause()
      this.resume()
    }
  }

  render() {
    this.slideTargets.forEach((slide, i) => {
      const active = i === this.index
      slide.style.opacity = active ? "1" : "0"
      slide.style.transform = active ? "scale(1)" : "scale(1.05)"
      slide.style.zIndex = active ? "1" : "0"
    })
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("bg-white", i === this.index)
      dot.classList.toggle("w-10", i === this.index)
      dot.classList.toggle("bg-white/40", i !== this.index)
      dot.classList.toggle("w-2", i !== this.index)
    })
  }
}

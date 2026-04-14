import { Controller } from "@hotwired/stimulus"

// Rotates through testimonial quotes with a fade transition.
//
//   <div data-controller="testimonial-carousel" data-testimonial-carousel-interval-value="6000">
//     <div data-testimonial-carousel-target="slide" class="opacity-100">Quote 1</div>
//     <div data-testimonial-carousel-target="slide" class="opacity-0">Quote 2</div>
//   </div>
export default class extends Controller {
  static targets = ["slide", "dot"]
  static values  = { interval: { type: Number, default: 5500 } }

  connect() {
    this.index = 0
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    if (this.slideTargets.length > 1) {
      this.timer = setInterval(() => this.next(), this.intervalValue)
    }
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  next() {
    this.goto(this.index + 1)
  }

  goto(index) {
    this.index = ((index % this.slideTargets.length) + this.slideTargets.length) % this.slideTargets.length
    this.slideTargets.forEach((slide, i) => {
      const active = i === this.index
      slide.style.opacity = active ? "1" : "0"
      slide.style.transform = active ? "translate3d(0, 0, 0)" : "translate3d(0, 1rem, 0)"
      slide.style.pointerEvents = active ? "auto" : "none"
    })
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("bg-blaze-red", i === this.index)
      dot.classList.toggle("w-8", i === this.index)
      dot.classList.toggle("bg-white/20", i !== this.index)
      dot.classList.toggle("w-2", i !== this.index)
    })
  }

  select(event) {
    const i = parseInt(event.currentTarget.dataset.index, 10)
    if (!Number.isNaN(i)) this.goto(i)
  }
}

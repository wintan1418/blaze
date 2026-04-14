import { Controller } from "@hotwired/stimulus"

// Netflix-style horizontal reel: drag-to-scroll, arrow buttons, optional auto-scroll.
// Set data-horizontal-scroll-auto-value="true" to enable the seamless auto-scroll loop.
// Auto-scroll pauses on hover and while dragging, and respects prefers-reduced-motion.
//
//   <div data-controller="horizontal-scroll"
//        data-horizontal-scroll-auto-value="true"
//        data-horizontal-scroll-speed-value="0.6">
//     <div data-horizontal-scroll-target="reel" class="snap-reel flex overflow-x-auto">
//       ...cards...
//     </div>
//     <button data-action="click->horizontal-scroll#prev">←</button>
//     <button data-action="click->horizontal-scroll#next">→</button>
//   </div>
export default class extends Controller {
  static targets = ["reel"]
  static values  = {
    step:  { type: Number,  default: 360 },
    auto:  { type: Boolean, default: false },
    speed: { type: Number,  default: 0.5 }
  }

  connect() {
    this.reel = this.hasReelTarget ? this.reelTarget : this.element

    this.isDown = false
    this.isHovered = false
    this.startX = 0
    this.scrollLeft = 0

    this.boundDown  = this.onDown.bind(this)
    this.boundMove  = this.onMove.bind(this)
    this.boundUp    = this.onUp.bind(this)
    this.boundEnter = this.onEnter.bind(this)
    this.boundLeave = this.onLeave.bind(this)

    this.reel.addEventListener("mousedown", this.boundDown)
    this.reel.addEventListener("mousemove", this.boundMove)
    this.reel.addEventListener("mouseleave", this.boundUp)
    this.reel.addEventListener("mouseup", this.boundUp)
    this.reel.addEventListener("mouseenter", this.boundEnter)
    this.reel.addEventListener("mouseleave", this.boundLeave)

    this.reel.style.cursor = "grab"
    this.reel.style.userSelect = "none"

    if (this.autoValue) this.enableAutoScroll()
  }

  disconnect() {
    this.reel.removeEventListener("mousedown", this.boundDown)
    this.reel.removeEventListener("mousemove", this.boundMove)
    this.reel.removeEventListener("mouseleave", this.boundUp)
    this.reel.removeEventListener("mouseup", this.boundUp)
    this.reel.removeEventListener("mouseenter", this.boundEnter)
    this.reel.removeEventListener("mouseleave", this.boundLeave)
    if (this.rafId) cancelAnimationFrame(this.rafId)
  }

  enableAutoScroll() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    // Duplicate children once so scrollLeft can loop seamlessly.
    this.reel.insertAdjacentHTML("beforeend", this.reel.innerHTML)
    this.halfWidth = this.reel.scrollWidth / 2

    const tick = () => {
      if (!this.isDown && !this.isHovered) {
        this.reel.scrollLeft += this.speedValue
        if (this.reel.scrollLeft >= this.halfWidth) {
          this.reel.scrollLeft -= this.halfWidth
        }
      }
      this.rafId = requestAnimationFrame(tick)
    }
    this.rafId = requestAnimationFrame(tick)
  }

  onEnter() { this.isHovered = true }
  onLeave() { this.isHovered = false }

  onDown(e) {
    this.isDown = true
    this.reel.style.cursor = "grabbing"
    this.startX = e.pageX - this.reel.offsetLeft
    this.scrollLeft = this.reel.scrollLeft
  }

  onMove(e) {
    if (!this.isDown) return
    e.preventDefault()
    const x = e.pageX - this.reel.offsetLeft
    const walk = (x - this.startX) * 1.5
    this.reel.scrollLeft = this.scrollLeft - walk
  }

  onUp() {
    this.isDown = false
    this.reel.style.cursor = "grab"
  }

  prev(event) {
    event?.preventDefault()
    this.reel.scrollBy({ left: -this.stepValue, behavior: "smooth" })
  }

  next(event) {
    event?.preventDefault()
    this.reel.scrollBy({ left: this.stepValue, behavior: "smooth" })
  }
}

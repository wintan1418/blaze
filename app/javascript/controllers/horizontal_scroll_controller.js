import { Controller } from "@hotwired/stimulus"

// Netflix-style horizontal reel: drag-to-scroll, smooth wheel, arrow buttons.
// If wrapped around a parent, put the scroll container on data-horizontal-scroll-target="reel"
// and the arrow buttons inside with data-action="click->horizontal-scroll#prev/next".
// For a simple setup, just apply the controller directly to the scroll container.
//
//   <div data-controller="horizontal-scroll">
//     <div data-horizontal-scroll-target="reel" class="snap-reel flex overflow-x-auto">
//       ...cards...
//     </div>
//     <button data-action="click->horizontal-scroll#prev">←</button>
//     <button data-action="click->horizontal-scroll#next">→</button>
//   </div>
export default class extends Controller {
  static targets = ["reel"]
  static values  = { step: { type: Number, default: 360 } }

  connect() {
    this.reel = this.hasReelTarget ? this.reelTarget : this.element

    this.isDown = false
    this.startX = 0
    this.scrollLeft = 0

    this.boundDown  = this.onDown.bind(this)
    this.boundMove  = this.onMove.bind(this)
    this.boundUp    = this.onUp.bind(this)

    this.reel.addEventListener("mousedown", this.boundDown)
    this.reel.addEventListener("mousemove", this.boundMove)
    this.reel.addEventListener("mouseleave", this.boundUp)
    this.reel.addEventListener("mouseup", this.boundUp)

    this.reel.style.cursor = "grab"
    this.reel.style.userSelect = "none"
  }

  disconnect() {
    this.reel.removeEventListener("mousedown", this.boundDown)
    this.reel.removeEventListener("mousemove", this.boundMove)
    this.reel.removeEventListener("mouseleave", this.boundUp)
    this.reel.removeEventListener("mouseup", this.boundUp)
  }

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

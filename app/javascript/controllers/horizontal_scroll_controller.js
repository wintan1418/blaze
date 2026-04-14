import { Controller } from "@hotwired/stimulus"

// Enables click-and-drag horizontal scrolling on the element (in addition to
// native wheel / swipe support). Useful for cinema reels, menu carousels.
//
//   <div data-controller="horizontal-scroll" class="overflow-x-auto">
//     ...items...
//   </div>
export default class extends Controller {
  connect() {
    this.isDown = false
    this.startX = 0
    this.scrollLeft = 0

    this.boundDown  = this.onDown.bind(this)
    this.boundMove  = this.onMove.bind(this)
    this.boundUp    = this.onUp.bind(this)

    this.element.addEventListener("mousedown", this.boundDown)
    this.element.addEventListener("mousemove", this.boundMove)
    this.element.addEventListener("mouseleave", this.boundUp)
    this.element.addEventListener("mouseup", this.boundUp)

    this.element.style.cursor = "grab"
    this.element.style.userSelect = "none"
  }

  disconnect() {
    this.element.removeEventListener("mousedown", this.boundDown)
    this.element.removeEventListener("mousemove", this.boundMove)
    this.element.removeEventListener("mouseleave", this.boundUp)
    this.element.removeEventListener("mouseup", this.boundUp)
  }

  onDown(e) {
    this.isDown = true
    this.element.style.cursor = "grabbing"
    this.startX = e.pageX - this.element.offsetLeft
    this.scrollLeft = this.element.scrollLeft
  }

  onMove(e) {
    if (!this.isDown) return
    e.preventDefault()
    const x = e.pageX - this.element.offsetLeft
    const walk = (x - this.startX) * 1.5
    this.element.scrollLeft = this.scrollLeft - walk
  }

  onUp() {
    this.isDown = false
    this.element.style.cursor = "grab"
  }
}

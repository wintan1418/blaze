import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    if (window.scrollY > 20) {
      this.element.classList.add("shadow-2xl", "shadow-black/30")
    } else {
      this.element.classList.remove("shadow-2xl", "shadow-black/30")
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Slide-in drawer for mobile menus. Works for either left or right drawers.
// The panel element declares its closed-state transform classes via
// data-drawer-closed-class, and the controller toggles those with
// `translate-x-0` on open/close.
//
//   <div data-controller="drawer">
//     <button data-action="click->drawer#toggle">☰</button>
//     <div data-drawer-target="panel"
//          data-drawer-closed-class="-translate-x-full pointer-events-none">
//       ...
//     </div>
//     <div data-drawer-target="backdrop" class="hidden"></div>
//   </div>
export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.open = false
    this.boundKey = this.onKey.bind(this)
    this.closedClasses = (this.panelTarget.dataset.drawerClosedClass || "translate-x-full pointer-events-none")
      .split(/\s+/).filter(Boolean)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKey)
    this.unlockScroll()
  }

  toggle() {
    this.open ? this.close() : this.show()
  }

  show() {
    this.open = true
    this.closedClasses.forEach((c) => this.panelTarget.classList.remove(c))
    this.panelTarget.classList.add("translate-x-0")

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("hidden", "opacity-0")
      this.backdropTarget.classList.add("opacity-100")
    }
    document.addEventListener("keydown", this.boundKey)
    this.lockScroll()
  }

  close() {
    this.open = false
    this.closedClasses.forEach((c) => this.panelTarget.classList.add(c))
    this.panelTarget.classList.remove("translate-x-0")

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("opacity-0")
      this.backdropTarget.classList.remove("opacity-100")
      setTimeout(() => this.backdropTarget.classList.add("hidden"), 300)
    }
    document.removeEventListener("keydown", this.boundKey)
    this.unlockScroll()
  }

  onKey(e) {
    if (e.key === "Escape") this.close()
  }

  lockScroll() {
    document.body.style.overflow = "hidden"
  }

  unlockScroll() {
    document.body.style.overflow = ""
  }
}

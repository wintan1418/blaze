import { Controller } from "@hotwired/stimulus"

// Adds .is-visible to any child with .reveal when it scrolls into view.
// Usage: add data-controller="reveal" to a section and .reveal to children.
export default class extends Controller {
  connect() {
    const targets = this.element.querySelectorAll(".reveal")
    if (targets.length === 0) return

    if (!("IntersectionObserver" in window)) {
      targets.forEach((el) => el.classList.add("is-visible"))
      return
    }

    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible")
            io.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15, rootMargin: "0px 0px -40px 0px" }
    )

    targets.forEach((el, i) => {
      el.style.transitionDelay = `${Math.min(i * 60, 400)}ms`
      io.observe(el)
    })
  }
}

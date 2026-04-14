import { Controller } from "@hotwired/stimulus"

// Splits the element's innerHTML into word spans and staggers them in with
// a subtle y-translate + opacity fade. Preserves inner span tags (for the
// fire-text accent word) by walking the DOM instead of string-replacing.
//
// Usage:
//   <h1 data-controller="text-reveal" data-text-reveal-stagger-value="60">
//     Taste the <span class="fire-text italic">fire</span>.
//   </h1>
export default class extends Controller {
  static values = {
    stagger:  { type: Number, default: 55 },
    duration: { type: Number, default: 900 }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.splitAndWrap()
    requestAnimationFrame(() => this.play())
  }

  // Recursively wrap every word inside the element in a span.reveal-word.
  // Spans (like the fire-text accent) are preserved whole so the gradient
  // fill doesn't break across wrapped words.
  splitAndWrap() {
    this.words = []
    this.walk(this.element)
  }

  walk(node) {
    const children = Array.from(node.childNodes)
    children.forEach((child) => {
      if (child.nodeType === Node.TEXT_NODE) {
        const text = child.textContent
        if (!text.trim()) return
        const frag = document.createDocumentFragment()
        const pieces = text.split(/(\s+)/)
        pieces.forEach((piece) => {
          if (!piece) return
          if (/^\s+$/.test(piece)) {
            frag.appendChild(document.createTextNode(piece))
          } else {
            const span = document.createElement("span")
            span.className = "reveal-word inline-block"
            span.textContent = piece
            span.style.opacity = "0"
            span.style.transform = "translate3d(0, 1.1em, 0)"
            span.style.transition = `opacity ${this.durationValue}ms cubic-bezier(0.22,1,0.36,1), transform ${this.durationValue}ms cubic-bezier(0.22,1,0.36,1)`
            span.style.willChange = "transform, opacity"
            this.words.push(span)
            frag.appendChild(span)
          }
        })
        node.replaceChild(frag, child)
      } else if (child.nodeType === Node.ELEMENT_NODE) {
        // Treat spans with their own class (e.g. fire-text) as atomic words —
        // wrap the whole element, don't recurse into it.
        if (child.tagName === "SPAN" && child.classList.length > 0) {
          const wrapper = document.createElement("span")
          wrapper.className = "reveal-word inline-block"
          wrapper.style.opacity = "0"
          wrapper.style.transform = "translate3d(0, 1.1em, 0)"
          wrapper.style.transition = `opacity ${this.durationValue}ms cubic-bezier(0.22,1,0.36,1), transform ${this.durationValue}ms cubic-bezier(0.22,1,0.36,1)`
          wrapper.style.willChange = "transform, opacity"
          node.insertBefore(wrapper, child)
          wrapper.appendChild(child)
          this.words.push(wrapper)
        } else {
          this.walk(child)
        }
      }
    })
  }

  play() {
    this.words.forEach((word, i) => {
      setTimeout(() => {
        word.style.opacity = "1"
        word.style.transform = "translate3d(0, 0, 0)"
      }, i * this.staggerValue)
    })
  }
}

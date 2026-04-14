import { Controller } from "@hotwired/stimulus"

// Click-to-copy a value from a data attribute to the clipboard.
// Usage:
//   <button data-controller="clipboard"
//           data-clipboard-value-value="BLZ-ABCD1234"
//           data-action="click->clipboard#copy">
//     <span data-clipboard-target="label">BLZ-ABCD1234</span>
//     <span data-clipboard-target="confirm" class="hidden">Copied!</span>
//   </button>
export default class extends Controller {
  static targets = ["label", "confirm"]
  static values  = { value: String, timeout: { type: Number, default: 1800 } }

  async copy(event) {
    event.preventDefault()
    try {
      await navigator.clipboard.writeText(this.valueValue)
      this.flashCopied()
    } catch (err) {
      // Fallback for older browsers
      const ta = document.createElement("textarea")
      ta.value = this.valueValue
      ta.style.position = "fixed"
      ta.style.opacity = "0"
      document.body.appendChild(ta)
      ta.select()
      try { document.execCommand("copy") } catch (e) { /* noop */ }
      document.body.removeChild(ta)
      this.flashCopied()
    }
  }

  flashCopied() {
    if (this.hasLabelTarget) this.labelTarget.classList.add("hidden")
    if (this.hasConfirmTarget) this.confirmTarget.classList.remove("hidden")
    this.element.classList.add("is-copied")

    if (this._timer) clearTimeout(this._timer)
    this._timer = setTimeout(() => {
      if (this.hasLabelTarget) this.labelTarget.classList.remove("hidden")
      if (this.hasConfirmTarget) this.confirmTarget.classList.add("hidden")
      this.element.classList.remove("is-copied")
    }, this.timeoutValue)
  }
}

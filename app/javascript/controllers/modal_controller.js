import { Controller } from "@hotwired/stimulus"

// Lightweight wrapper around the native <dialog> element.
// Usage:
//   <div data-controller="modal">
//     <button data-action="modal#open">Open</button>
//     <dialog data-modal-target="dialog" data-action="click->modal#backdropClose">
//       <div data-modal-target="panel">...</div>
//       <button data-action="modal#close">×</button>
//     </dialog>
//   </div>
export default class extends Controller {
  static targets = ["dialog", "panel"]

  open(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget) return
    if (typeof this.dialogTarget.showModal === "function") {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.setAttribute("open", "")
    }
    document.body.style.overflow = "hidden"
  }

  close(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget) return
    if (typeof this.dialogTarget.close === "function") {
      this.dialogTarget.close()
    } else {
      this.dialogTarget.removeAttribute("open")
    }
    document.body.style.overflow = ""
  }

  // Close when clicking the backdrop (dialog element itself, outside the panel).
  backdropClose(event) {
    if (!this.hasPanelTarget) return
    if (event.target === this.dialogTarget) this.close(event)
  }
}

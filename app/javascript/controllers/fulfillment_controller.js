import { Controller } from "@hotwired/stimulus"

// Shows/hides delivery-specific fields when the fulfillment radio changes.
// Progressive enhancement: delivery blocks are visible in the markup so the
// form still works without JS. On connect we hide them if non-delivery is selected.
export default class extends Controller {
  static targets = ["delivery", "deliveryFee"]

  connect() {
    this.toggle()
  }

  toggle() {
    const radio = this.element.querySelector('input[name="order[fulfillment]"]:checked')
    const showDelivery = radio?.value === "delivery"

    this.deliveryTargets.forEach((el) => el.classList.toggle("hidden", !showDelivery))
    if (this.hasDeliveryFeeTarget) {
      this.deliveryFeeTargets.forEach((el) => el.classList.toggle("hidden", !showDelivery))
    }
  }
}

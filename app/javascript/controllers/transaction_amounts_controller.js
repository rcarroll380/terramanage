import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["payment", "deposit"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const hasPayment = this.paymentTarget.value.trim() !== ""
    const hasDeposit = this.depositTarget.value.trim() !== ""

    this.depositTarget.closest(".transaction-amount-field").hidden = hasPayment && !hasDeposit
    this.paymentTarget.closest(".transaction-amount-field").hidden = hasDeposit && !hasPayment
  }
}

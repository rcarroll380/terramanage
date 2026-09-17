import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.hideSelectedType()
  }

  showTypes() {
    this.selectTarget.options.forEach((option) => {
      if (option.dataset.displayName) option.textContent = option.dataset.fullLabel || option.textContent
    })
  }

  hideSelectedType() {
    this.selectTarget.options.forEach((option) => {
      if (option.dataset.displayName) {
        option.dataset.fullLabel ||= option.textContent
      }
    })

    const selected = this.selectTarget.selectedOptions[0]
    if (selected?.dataset.displayName) selected.textContent = selected.dataset.displayName
  }
}

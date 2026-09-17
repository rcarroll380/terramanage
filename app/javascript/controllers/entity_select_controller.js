import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.hideSelectedType()
  }

  showTypes() {
    this.selectTarget.options.forEach((option) => {
      if (option.dataset.displayName) option.text = option.dataset.fullLabel || option.text
    })
  }

  hideSelectedType() {
    this.selectTarget.options.forEach((option) => {
      if (option.dataset.displayName) {
        option.dataset.fullLabel ||= option.text
      }
    })

    const selected = this.selectTarget.selectedOptions[0]
    if (selected?.dataset.displayName) selected.text = selected.dataset.displayName
  }
}

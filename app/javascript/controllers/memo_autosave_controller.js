import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    const form = this.element.form
    if (form?.checkValidity()) form.requestSubmit()
  }
}

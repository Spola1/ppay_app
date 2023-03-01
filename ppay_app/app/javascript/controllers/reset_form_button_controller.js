import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset-form-button"
export default class extends Controller {
  clear() {
    this.element.reset()
  }
}

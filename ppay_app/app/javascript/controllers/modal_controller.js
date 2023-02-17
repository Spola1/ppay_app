import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal" ]

  hide() {
    this.element.classList.remove("show")
  }
}
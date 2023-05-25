import { Controller } from "@hotwired/stimulus"
import "inputmask"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    Inputmask({ regex: "[\\d\\w]{4}( [\\d\\w]{4})*" }).mask(this.inputTargets)
  }
}

import { Controller } from "@hotwired/stimulus"
import "inputmask"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // console.log(Inputmask)
    Inputmask('9999 9999 9999 9999').mask(this.inputTargets)
  }
}

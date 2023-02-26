import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ]

  copy() {
    const source = this.sourceTarget.textContent.trim();
    navigator.clipboard.writeText(source)
  }
}
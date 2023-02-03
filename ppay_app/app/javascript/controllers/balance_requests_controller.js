import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['cryptoAddress', 'type']

  connect() {
    this.toggleCryptoAddress()
  }

  toggleCryptoAddress() {
    this.typeTarget.value == 'withdraw' ? $(this.cryptoAddressTarget).show() : $(this.cryptoAddressTarget).hide()
  }
}

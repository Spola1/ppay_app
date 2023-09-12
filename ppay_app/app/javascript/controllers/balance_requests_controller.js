import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['type', 'amount', 'amountMinusCommission', 'withdraw', 'balanceRequestsCommission']

  connect() {
    this.toggleWithdraw()
  }

  toggleWithdraw() {
    if (this.typeTarget.value == 'withdraw') {
      $(this.withdrawTarget).show()
    } else {
      $(this.withdrawTarget).hide()
      this.amountMinusCommissionTarget.value = null
    }
  }

  get commission() {
    return parseFloat(this.balanceRequestsCommissionTarget.value)
  }

  inputAmount() {
    if (this.typeTarget.value == 'deposit') return

    let value = parseFloat(this.amountTarget.value)

    if (value > this.commission) {
      this.amountMinusCommissionTarget.value = (value - this.commission).toFixed(2)
    } else {
      this.amountMinusCommissionTarget.value = null
    }
  }

  inputAmountMinusCommission() {
    let value = parseFloat(this.amountMinusCommissionTarget.value)

    if (value == 0) {
      this.amountTarget.value = 0
    } else if (isNaN(value)) {
      this.amountTarget.value = null
    } else {
      this.amountTarget.value = (value + this.commission).toFixed(2)
    }
  }
}

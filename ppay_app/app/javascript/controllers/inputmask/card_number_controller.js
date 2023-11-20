import { Controller } from "@hotwired/stimulus"
import "inputmask"

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.applyInputMask();
    this.loadPaymentSystem();
  }

  applyInputMask() {
    const paymentSystem = this.data.get("paymentSystem");
    const inputTargets = this.inputTargets;

    if (this.isERIP(paymentSystem)) {
      Inputmask({ regex: "[\\d\\w\\/]*" }).mask(inputTargets);
    } else if (this.isSBP(paymentSystem)) {
      Inputmask({ regex: "\\+[0-9]*" }).mask(inputTargets);
    } else {
      Inputmask({ regex: "[\\d\\w]{4}( [\\d\\w]{4})*" }).mask(inputTargets);
    }
  }

  isERIP(paymentSystem) {
    return ["ЕРИП БНБ", "ЕРИП Альфа", "ЕРИП Белагро"].includes(paymentSystem);
  }

  isSBP(paymentSystem) {
    return paymentSystem === "СБП";
  }

  loadPaymentSystem() {
    const paymentSystemSelect = document.getElementById("advertisement_payment_system");
    paymentSystemSelect.addEventListener("change", (event) => {
      this.data.set("paymentSystem", event.target.value);
      this.applyInputMask();
    });
  }
}

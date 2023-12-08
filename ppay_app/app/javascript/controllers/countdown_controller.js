import { Controller } from "@hotwired/stimulus"
import "jquery-countdown"

export default class extends Controller {
  static targets = ["countdown"]

  connect() {
    $(this.countdownTargets).each(function() {
      $(this).countdown(Date.parse($(this).data('endTime')), function(event) {
        $(this).text(
          event.strftime('%H:%M:%S')
        )
      })
    })
  }
}

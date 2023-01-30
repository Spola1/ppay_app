import { Controller } from "@hotwired/stimulus"
import "jquery-countdown"

export default class extends Controller {
  static targets = ["countdown"]

  connect() {
    $(this.countdownTargets).each(function() {
      $(this).countdown($(this).data('endTime'), function(event) {
        $(this).text(
          event.strftime('%H:%M:%S')
        )
      })
    })
  }
}

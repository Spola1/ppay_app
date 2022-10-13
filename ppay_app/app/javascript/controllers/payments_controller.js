import { Controller } from "@hotwired/stimulus"

import 'jquery-countdown'

export default class extends Controller {
  connect() {
    $(".countdown")
    .countdown($(".countdown").data('endTime'), function(event) {
      $(this).text(
        event.strftime('%H:%M:%S')
      );
    });
  }
}

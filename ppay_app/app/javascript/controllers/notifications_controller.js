import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    $('#notification_sound').get(0).play()

    $(this.element).show('slide', { direction: 'right' }, 200)

    setTimeout(() => {
      $(this.element).hide('slide', { direction: 'right' }, 200, () => {
        this.element.remove()
      })
    }, 5000)
  }
}

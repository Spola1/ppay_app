import { Controller } from "@hotwired/stimulus"
import { FilePondRails, FilePond } from 'filepond-rails'
import ru_RU from 'filepond-ru'
import FilePondPluginImagePreview from 'filepond-plugin-image-preview'
import FilePondPluginFileValidateSize from 'filepond-plugin-file-validate-size'

FilePond.registerPlugin(
  FilePondPluginImagePreview,
  FilePondPluginFileValidateSize
)
FilePond.setOptions(ru_RU)

window.FilePond = FilePond
window.FilePondRails = FilePondRails

export default class extends Controller {
  static targets = ['input'];

  connect() {
    const input = document.querySelector('.filepond')
    FilePondRails.create(input)
  }
}
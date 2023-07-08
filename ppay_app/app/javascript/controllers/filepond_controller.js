import { Controller } from "@hotwired/stimulus"
import { FilePondRails, FilePond } from 'filepond-rails'
import ru_RU from 'filepond-ru'
import uk_UA from 'filepond-uk'
//import uz_UZ from 'filepond-uz'
//import tg_TG from 'filepond-tg'
import id_ID from 'filepond-id'
//import kk_KK from 'filepond-kk'
import tr_TR from 'filepond-tr'
//import ky_KY from 'filepond-ky'

import FilePondPluginImagePreview from 'filepond-plugin-image-preview'
import FilePondPluginFileValidateSize from 'filepond-plugin-file-validate-size'

FilePond.registerPlugin(
  FilePondPluginImagePreview,
  FilePondPluginFileValidateSize
)

const languagePacks = {
  'ru-ru': ru_RU,
  'uk-ua': uk_UA,
//  'uz-uz': uz_UZ,
//  'tg-tg': tg_TG,
  'id-id': id_ID,
//  'kk-kk': kk_KK,
  'tr-tr': tr_TR,
//  'ky-ky': ky_KY
}

window.FilePond = FilePond
window.FilePondRails = FilePondRails

export default class extends Controller {
  static targets = ['input'];

  connect() {
    const input = document.querySelector('.filepond');
    const languagePack = ru_RU // languagePacks[window.paymentLanguage] || ru_RU;
    FilePond.setOptions(languagePack);
    FilePondRails.create(input);
  }
}

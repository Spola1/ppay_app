# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'jquery-countdown', to: 'https://ga.jspm.io/npm:jquery-countdown@2.2.0/dist/jquery.countdown.js'
pin 'inputmask', to: 'https://ga.jspm.io/npm:inputmask@5.0.7/dist/inputmask.js'
pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js'
pin 'jquery-ui', to: 'https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/jquery-ui.min.js'
pin 'filepond', to: 'https://ga.jspm.io/npm:filepond@4.30.4/dist/filepond.js', preload: true
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@7.0.2/app/assets/javascripts/activestorage.esm.js"
pin "filepond-plugin-image-preview", to: "https://ga.jspm.io/npm:filepond-plugin-image-preview@4.6.11/dist/filepond-plugin-image-preview.js"
pin "filepond-plugin-file-validate-size", to: "https://ga.jspm.io/npm:filepond-plugin-file-validate-size@2.2.8/dist/filepond-plugin-file-validate-size.js"

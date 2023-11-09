# frozen_string_literal: true

FactoryBot.define do
  factory :incoming_request do
    from { 'Raiffeisen' }
    request_type { 'SMS' }
    identifier { 'phone' }
    phone { '79231636742' }
    app { 'SMS Forwarder' }
    message { 'Schet *8412. Platezh s nomera 79529048819. Summa 100,00 RUB. Balans 94,87 RUB.' }
  end
end

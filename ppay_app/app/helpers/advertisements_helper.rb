# frozen_string_literal: true

module AdvertisementsHelper
  def simbank_identifier_hint
    simple_format('Для PUSH - IMEI устройства где установлено приложение в формате: 1234567890123
    Для SMS через приложение - номер телефона в формате: 79232005555
    Для SMS через SIM-банк - номер IMSI в формате: 1234567890123')
  end

  def simbank_card_number_hint
    '*Указывается только если такая информация есть в SMS или PUSH'
  end

  def simbank_sender_hint
    '*Например 900 или Тинькофф'
  end
end

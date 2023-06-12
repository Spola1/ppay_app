# frozen_string_literal: true

# внесение средств на баланс = операция по продаже (sell)
class Deposit < Payment
  include StateMachines::Payments::Deposit
  include Payments::Transactions::Deposit

  def language_from_locale
    language_mapping = {
      'ru' => 'ru-ru',
      'uk' => 'uk-ua',
      'uz' => 'uz-uz',
      'tg' => 'tg-tg',
      'id' => 'id-id',
      'kk' => 'kk-kk',
      'tr' => 'tr-tr',
      'ky' => 'ky-ky'
    }

    language_mapping[locale] || 'ru-ru'
  end
end

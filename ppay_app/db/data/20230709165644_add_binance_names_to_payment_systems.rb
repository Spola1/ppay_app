# frozen_string_literal: true

class AddBinanceNamesToPaymentSystems < ActiveRecord::Migration[7.0]
  def up
    ApplicationRecord.connection.schema_cache.clear!
    ApplicationRecord.reset_column_information

    [
      ['Sberbank',                   'RosBankNew'],
      ['Tinkoff',                    'TinkoffNew'],
      ['Raiffeisen',                 'RaiffeisenBank'],
      ['AlfaBank',                   ''],
      ['HUMO',                       'Humo'],
      ['Банк ЦентрКредит',           'CenterCreditBank'],
      ['Halyk Bank',                 'HalykBank'],
      ['Jusan Bank',                 'JysanBank'],
      ['Kaspi Bank',                 'KaspiBank'],
      ['IBAN',                       ''],
      ['PrivatBank',                 'PrivatBank'],
      ['MonoBank',                   'Monobank'],
      ['PUMB',                       'PUMBBank'],
      ['PermataBank',                'PermataMe'],
      ['Optima24',                   'OPTIMABANK'],
      ['Halyk',                      'HalykBank'],
      ['Bakai24',                    'BAKAIBANK'],
      ['Demir',                      'DEMIRBANK'],
      ['UzCard',                     'Uzcard'],
      ['Dushanbe City - КортиМилли', 'DCbank'],
      ['Alif - VISA',                'AlifBank'],
      ['Alif - КортиМилли',          'AlifBank'],
      ['Спитамен - VISA',            'SpitamenBank'],
      ['Спитамен - КортиМилли',      'SpitamenBank'],
    ].each do |name, binance_name|
      ps = PaymentSystem.find_by(name:)

      next unless ps

      ps.update(binance_name:) if binance_name.present?
    end
  end
end

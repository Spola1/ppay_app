# frozen_string_literal: true

class AppendPaymentSystems < ActiveRecord::Migration[7.0]
  def up
    PaymentSystem.create(
      [
        { name: 'Банк ЦентрКредит' },
        { name: 'Halyk Bank' },
        { name: 'Jusan Bank' },
        { name: 'Kaspi Bank' },
        { name: 'Другой банк' },
        { name: 'IBAN' },
        { name: 'PrivatBank' },
        { name: 'MonoBank' },
        { name: 'PUMB' },
        { name: 'PermataBank' },
        { name: 'Optima24' },
        { name: 'Halyk' },
        { name: 'Bakai24' },
        { name: 'Demir' },
        { name: 'UzCard' }
      ]
    )
  end
end

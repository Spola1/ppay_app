# frozen_string_literal: true

class AppendPaymentSystems < ActiveRecord::Migration[7.0]
  class PaymentSystem < ApplicationRecord; end

  def up
    PaymentSystem.create!(
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
        { name: 'UzCard' },
        { name: 'Dushanbe City - КортиМилли' },
        { name: 'Alif - VISA' },
        { name: 'Alif - КортиМилли' },
        { name: 'Спитамен - VISA' },
        { name: 'Спитамен - КортиМилли' }
      ]
    )
  end
end

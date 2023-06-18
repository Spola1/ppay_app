# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    PaymentSystem.delete_all
    NationalCurrency.delete_all

    PaymentSystem.create([{ name: 'Sberbank' }, { name: 'Tinkoff' }])
    NationalCurrency.create([{ name: 'RUB' }, { name: 'IDR' }])
  end
end

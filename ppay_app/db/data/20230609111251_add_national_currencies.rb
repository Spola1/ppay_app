# frozen_string_literal: true

class AddNationalCurrencies < ActiveRecord::Migration[7.0]
  class NationalCurrency < ApplicationRecord;  end

  def up
    NationalCurrency.create(
      [
        { name: 'RUB' },
        { name: 'UZS' },
        { name: 'TJS' },
        { name: 'IDR' },
        { name: 'KZT' },
        { name: 'UAH' },
        { name: 'TRY' },
        { name: 'KGS' }
      ]
    )
  end
end

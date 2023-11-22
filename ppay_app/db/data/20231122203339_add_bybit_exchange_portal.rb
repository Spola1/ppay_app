# frozen_string_literal: true

class AddBybitExchangePortal < ActiveRecord::Migration[7.0]
  def up
    ExchangePortal.create(name: 'Bybit P2P')
  end
end

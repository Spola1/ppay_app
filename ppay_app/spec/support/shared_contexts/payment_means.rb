# frozen_string_literal: true

shared_context 'payment means' do
  let!(:national_currency) { create(:national_currency, name: 'RUB') }
  let!(:exchange_portal) { create(:exchange_portal, name: 'Binance P2P') }
  let!(:payment_system) { create(:payment_system, national_currency:, exchange_portal:) }
end

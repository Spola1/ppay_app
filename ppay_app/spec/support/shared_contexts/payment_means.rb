# frozen_string_literal: true

shared_context 'payment means' do
  let!(:national_currency) { create(:national_currency, name: 'RUB') }
  let!(:payment_system) { create(:payment_system) }
end

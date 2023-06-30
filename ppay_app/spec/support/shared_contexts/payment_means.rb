# frozen_string_literal: true

shared_context 'payment means' do
  let(:payment_system) { PaymentSystem.first }
  let(:national_currency) { NationalCurrency.first }
end

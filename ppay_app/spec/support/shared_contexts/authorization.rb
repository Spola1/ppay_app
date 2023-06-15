# frozen_string_literal: true

shared_context 'authorization' do
  let(:Authorization) { "Bearer #{merchant_token}" }
  let(:invalid_merchant_token) { Base64.strict_encode64('bogus:bogus') }
  let(:valid_merchant_token) { merchant.api_keys.first.token }

  let!(:merchant) { create :merchant, check_required: }
  let(:merchant_token) { valid_merchant_token }
  let(:check_required) { true }
end

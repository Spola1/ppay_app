# frozen_string_literal: true

shared_context 'merchant authorization' do
  let!(:payment_system) { create :payment_system }
  let!(:merchant) { create :merchant, check_required:, account_number_required: }
  let(:check_required) { true }
  let(:account_number_required) { false }

  let(:valid_merchant_token) { merchant.api_keys.first.token }
  let(:invalid_merchant_token) { Base64.strict_encode64('bogus:bogus') }
  let(:merchant_token) { valid_merchant_token }

  let(:bearer_user) { nil }
  let(:bearer_user_token) { bearer_user ? bearer_user.api_keys.first.token : merchant_token }
  let(:Authorization) { "Bearer #{bearer_user_token}" }
end

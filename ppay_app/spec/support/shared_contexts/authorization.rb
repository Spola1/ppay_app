# frozen_string_literal: true

shared_context 'authorization' do
  let(:Authorization) { "Bearer #{user_token}" }
  let(:invalid_token) { ::Base64.strict_encode64('bogus:bogus') }
  let(:valid_token) { user.api_keys.first.token }
  let!(:user) { create(:user, :merchant).becomes(Merchant) }
  let(:user_token) { valid_token }
end

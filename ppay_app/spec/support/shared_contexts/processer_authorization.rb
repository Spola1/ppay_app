# frozen_string_literal: true

shared_context 'processer authorization' do
  let!(:processer) { create :processer }

  let(:valid_processer_token) { processer.api_keys.first.token }
  let(:invalid_processer_token) { Base64.strict_encode64('bogus:bogus') }
  let(:processer_token) { valid_processer_token }

  let(:bearer_user) { nil }
  let(:bearer_user_token) { bearer_user ? bearer_user.api_keys.first.token : processer_token }
  let(:Authorization) { "Bearer #{bearer_user_token}" }
end

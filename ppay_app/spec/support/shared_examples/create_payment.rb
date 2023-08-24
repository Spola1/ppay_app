# frozen_string_literal: true

shared_examples 'create_payment' do |type:|
  let(:currency) { 'RUB' }

  include_context 'successful_creation_response', { type: }

  include_context 'invalid_response', { type: }

  include_context 'unauthorized_response'
end

shared_context 'invalid_response' do |type:|
  let(:currency) { 'RUB' }

  response '422', 'invalid' do
    include_context 'generate_examples'

    context 'валюты нет в списке доступных' do
      let(:currency) { 'USD' }

      let(:expected_errors) do
        [
          { 'title' => 'national_currency', 'detail' => national_currency_error, 'code' => 422 }
        ]
      end

      let(:national_currency_error) { "Доступные значения #{NationalCurrency.pluck(:name).join(', ')}" }

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end
  end
end

shared_context 'successful_creation_response' do |type:|
  response '201', 'успешное создание' do
    schema '$ref': '#/components/schemas/payments_create_response_body_schema'

    include_context 'generate_examples'

    context 'validates schema' do
      run_test!
    end

    it 'создаст платеж мерчанту' do |example|
      expect { submit_request(example.metadata) }.to change {
        merchant.reload.public_send(payment_type.to_s.underscore.pluralize).count
      }.from(0).to(1)

      assert_response_matches_metadata(example.metadata)
    end

    it 'sets unique_amount', if: type == :deposit do |example|
      submit_request(example.metadata)

      expect(merchant.deposits.last.unique_amount).to eq(merchant.unique_amount)
    end
  end
end

shared_context 'unauthorized_response' do
  response '401', 'unauthorized' do
    let(:merchant_token) { invalid_merchant_token }

    run_test!
  end
end

# frozen_string_literal: true

shared_examples 'create_payment' do
  parameter name: :params,
            in: :body,
            schema: { '$ref' => '#/components/schemas/payments_create_parameter_body_schema' }

  include_context 'create_params'

  let(:currency) { 'RUB' }

  include_context 'successful_creation_response'

  include_context 'invalid_response'

  include_context 'unauthorized_response'
end

shared_context 'create_params' do
  let(:params) do
    {
      national_currency: currency,
      national_currency_amount: 3000.0,
      external_order_id: '1234',
      redirect_url: FFaker::Internet.http_url,
      callback_url: FFaker::Internet.http_url
    }
  end
end

shared_context 'invalid_response' do
  response '422', 'invalid' do
    include_context 'generate_examples'

    context 'валюты нет в списке доступных' do
      let(:currency) { 'USD' }

      let(:expected_errors) do
        [
          { 'title' => 'national_currency', 'detail' => national_currency_error, 'code' => 422 }
        ]
      end

      let(:national_currency_error) { "Доступные значения #{Settings.national_currencies.join(', ')}" }

      run_test! do |_response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end
  end
end

shared_context 'successful_creation_response' do
  response '201', 'успешное создание' do
    include_context 'generate_examples'

    it 'создаст платеж мерчанту' do |example|
      expect { submit_request(example.metadata) }.to change {
        user.reload.public_send(payment_type.to_s.underscore.pluralize).count
      }.from(0).to(1)

      assert_response_matches_metadata(example.metadata)
    end
  end
end

shared_context 'unauthorized_response' do
  response '401', 'unauthorized' do
    let(:user_token) { invalid_token }

    run_test!
  end
end

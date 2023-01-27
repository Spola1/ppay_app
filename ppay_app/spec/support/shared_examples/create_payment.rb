shared_examples 'create_payment' do
  parameter name: :params,
            in: :body,
            schema: { '$ref' => '#/components/schemas/payments_create_parameter_body_schema' }

  let(:params) do
    {
      national_currency: currency,
      national_currency_amount: 3000.0,
      external_order_id: '1234',
    }
  end

  let(:currency) { 'RUB' }

  response '201', 'успешное создание' do
    it 'создаст платеж мерчанту' do |example|
      expect { submit_request(example.metadata) }.to change {
        user.reload.public_send(payment_type.to_s.underscore.pluralize).count
      }.from(0).to(1)

      assert_response_matches_metadata(example.metadata)
    end
  end

  response '422', 'invalid' do
    context 'валюты нет в списке доступных' do
      let(:currency) { 'USD' }

      let(:expected_errors) do
        [
          { 'title' => 'national_currency', 'detail' => national_currency_error, 'code' => 422 }
        ]
      end

      let(:national_currency_error) { "Доступные значения #{Settings.national_currencies.join(', ')}" }

      run_test! do |response|
        expect(response_body['errors']).to eq(expected_errors)
      end
    end
  end

  response '401', 'unauthorized' do
    let(:user_token) { invalid_token }

    run_test!
  end
end

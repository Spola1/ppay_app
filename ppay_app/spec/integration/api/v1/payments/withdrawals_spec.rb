require 'swagger_helper'

describe 'Платежи' do
  include_context 'authorization'

  let!(:rate_snapshot) { create(:rate_snapshot) }

  path '/api/v1/payments/withdrawals' do
    post 'Создание вывода средств' do
      tags 'Платежи'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      parameter name: :params,
                in: :body,
                schema: { '$ref' => '#/components/schemas/payments_create_parameter_body_schema' }

      let(:params) do
        {
          national_currency: 'RUB',
          national_currency_amount: 3000.0,
          external_order_id: '1234',
        }
      end

      response '201', 'успешное создание' do
        let(:user_token) { valid_token }

        it 'создаст платеж мерчанту' do |example|
          expect { submit_request(example.metadata) }.to change { user.reload.withdrawals.count }.from(0).to(1)
          assert_response_matches_metadata(example.metadata)
        end
      end

      response '401', 'unauthorized' do
        let(:user_token) { invalid_token }

        run_test!
      end
    end
  end
end

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

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments/withdrawals.md'))

      let(:payment_type) { Withdrawal }

      it_behaves_like 'create_payment'
    end
  end
end
